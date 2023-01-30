/**
 *Submitted for verification at Etherscan.io on 2020-02-20
*/

/**
Author: Authereum Labs, Inc.
*/

pragma solidity 0.5.16;


contract Owned {

    // The owner
    address public owner;

    event OwnerChanged(address indexed _newOwner);

    /// @dev Throws if the sender is not the owner
    modifier onlyOwner {
        require(msg.sender == owner, "O: Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /// @dev Return the ownership status of an address
    /// @param _potentialOwner Address being checked
    /// @return True if the _potentialOwner is the owner
    function isOwner(address _potentialOwner) external view returns (bool) {
        return owner == _potentialOwner;
    }

    /// @dev Lets the owner transfer ownership of the contract to a new owner
    /// @param _newOwner The new owner
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "O: Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

contract Managed is Owned {

    // The managers
    mapping (address => bool) public managers;

    /// @dev Throws if the sender is not a manager
    modifier onlyManager {
        require(managers[msg.sender] == true, "M: Must be manager");
        _;
    }

    event ManagerAdded(address indexed _manager);
    event ManagerRevoked(address indexed _manager);

    /// @dev Adds a manager
    /// @param _manager The address of the manager
    function addManager(address _manager) external onlyOwner {
        require(_manager != address(0), "M: Address must not be null");
        if(managers[_manager] == false) {
            managers[_manager] = true;
            emit ManagerAdded(_manager);
        }
    }

    /// @dev Revokes a manager
    /// @param _manager The address of the manager
    function revokeManager(address _manager) external onlyOwner {
        require(managers[_manager] == true, "M: Target must be an existing manager");
        delete managers[_manager];
        emit ManagerRevoked(_manager);
    }
}

contract EnsRegistry {

    struct Record {
        address owner;
        address resolver;
        uint64 ttl;
    }

    mapping(bytes32=>Record) records;

    // Logged when the owner of a node assigns a new owner to a subnode.
    event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);

    // Logged when the owner of a node transfers ownership to a new account.
    event Transfer(bytes32 indexed _node, address _owner);

    // Logged when the resolver for a node changes.
    event NewResolver(bytes32 indexed _node, address _resolver);

    // Logged when the TTL of a node changes
    event NewTTL(bytes32 indexed _node, uint64 _ttl);

    // Permits modifications only by the owner of the specified node.
    modifier only_owner(bytes32 _node) {
        require(records[_node].owner == msg.sender, "ENSTest: this method needs to be called by the owner of the node");
        _;
    }

    /**
     * Constructs a new ENS registrar.
     */
    constructor() public {
        records[bytes32(0)].owner = msg.sender;
    }

    /**
     * Returns the address that owns the specified node.
     */
    function owner(bytes32 _node) public view returns (address) {
        return records[_node].owner;
    }

    /**
     * Returns the address of the resolver for the specified node.
     */
    function resolver(bytes32 _node) public view returns (address) {
        return records[_node].resolver;
    }

    /**
     * Returns the TTL of a node, and any records associated with it.
     */
    function ttl(bytes32 _node) public view returns (uint64) {
        return records[_node].ttl;
    }

    /**
     * Transfers ownership of a node to a new address. May only be called by the current
     * owner of the node.
     * @param _node The node to transfer ownership of.
     * @param _owner The address of the new owner.
     */
    function setOwner(bytes32 _node, address _owner) public only_owner(_node) {
        emit Transfer(_node, _owner);
        records[_node].owner = _owner;
    }

    /**
     * Transfers ownership of a subnode sha3(node, label) to a new address. May only be
     * called by the owner of the parent node.
     * @param _node The parent node.
     * @param _label The hash of the label specifying the subnode.
     * @param _owner The address of the new owner.
     */
    function setSubnodeOwner(bytes32 _node, bytes32 _label, address _owner) public only_owner(_node) {
        bytes32 subnode = keccak256(abi.encodePacked(_node, _label));
        emit NewOwner(_node, _label, _owner);
        records[subnode].owner = _owner;
    }

    /**
     * Sets the resolver address for the specified node.
     * @param _node The node to update.
     * @param _resolver The address of the resolver.
     */
    function setResolver(bytes32 _node, address _resolver) public only_owner(_node) {
        emit NewResolver(_node, _resolver);
        records[_node].resolver = _resolver;
    }

    /**
     * Sets the TTL for the specified node.
     * @param _node The node to update.
     * @param _ttl The TTL in seconds.
     */
    function setTTL(bytes32 _node, uint64 _ttl) public only_owner(_node) {
        emit NewTTL(_node, _ttl);
        records[_node].ttl = _ttl;
    }
}

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

contract EnsResolver {

    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;
    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;
    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;
    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;
    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;
    bytes4 constant CONTENTHASH_INTERFACE_ID = 0xbc1c58d1;

    event AddrChanged(bytes32 indexed node, address a);
    event NameChanged(bytes32 indexed node, string name);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexedKey, string key);
    event ContenthashChanged(bytes32 indexed node, bytes hash);

    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    struct Record {
        address addr;
        string name;
        PublicKey pubkey;
        mapping(string=>string) text;
        mapping(uint256=>bytes) abis;
        bytes contenthash;
    }

    ENS ens;

    mapping (bytes32 => Record) records;

    modifier onlyOwner(bytes32 node) {
        require(ens.owner(node) == msg.sender);
        _;
    }

    /**
     * Constructor.
     * @param ensAddr The ENS registrar contract.
     */
    constructor(ENS ensAddr) public {
        ens = ensAddr;
    }

    /**
     * Sets the address associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param addr The address to set.
     */
    function setAddr(bytes32 node, address addr) public onlyOwner(node) {
        records[node].addr = addr;
        emit AddrChanged(node, addr);
    }

    /**
     * Sets the contenthash associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param hash The contenthash to set
     */
    function setContenthash(bytes32 node, bytes memory hash) public onlyOwner(node) {
        records[node].contenthash = hash;
        emit ContenthashChanged(node, hash);
    }

    /**
     * Sets the name associated with an ENS node, for reverse records.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param name The name to set.
     */
    function setName(bytes32 node, string memory name) public onlyOwner(node) {
        records[node].name = name;
        emit NameChanged(node, name);
    }

    /**
     * Sets the ABI associated with an ENS node.
     * Nodes may have one ABI of each content type. To remove an ABI, set it to
     * the empty string.
     * @param node The node to update.
     * @param contentType The content type of the ABI
     * @param data The ABI data.
     */
    function setABI(bytes32 node, uint256 contentType, bytes memory data) public onlyOwner(node) {
        // Content types must be powers of 2
        require(((contentType - 1) & contentType) == 0);

        records[node].abis[contentType] = data;
        emit ABIChanged(node, contentType);
    }

    /**
     * Sets the SECP256k1 public key associated with an ENS node.
     * @param node The ENS node to query
     * @param x the X coordinate of the curve point for the public key.
     * @param y the Y coordinate of the curve point for the public key.
     */
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) public onlyOwner(node) {
        records[node].pubkey = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }

    /**
     * Sets the text data associated with an ENS node and key.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param key The key to set.
     * @param value The text data value to set.
     */
    function setText(bytes32 node, string memory key, string memory value) public onlyOwner(node) {
        records[node].text[key] = value;
        emit TextChanged(node, key, key);
    }

    /**
     * Returns the text data associated with an ENS node and key.
     * @param node The ENS node to query.
     * @param key The text data key to query.
     * @return The associated text data.
     */
    function text(bytes32 node, string memory key) public view returns (string memory) {
        return records[node].text[key];
    }

    /**
     * Returns the SECP256k1 public key associated with an ENS node.
     * Defined in EIP 619.
     * @param node The ENS node to query
     * @return x, y the X and Y coordinates of the curve point for the public key.
     */
    function pubkey(bytes32 node) public view returns (bytes32 x, bytes32 y) {
        return (records[node].pubkey.x, records[node].pubkey.y);
    }

    /**
     * Returns the ABI associated with an ENS node.
     * Defined in EIP205.
     * @param node The ENS node to query
     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.
     * @return contentType The content type of the return value
     * @return data The ABI data
     */
    function ABI(bytes32 node, uint256 contentTypes) public view returns (uint256 contentType, bytes memory data) {
        Record storage record = records[node];
        for (contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {
                data = record.abis[contentType];
                return (contentType, data);
            }
        }
        contentType = 0;
    }

    /**
     * Returns the name associated with an ENS node, for reverse records.
     * Defined in EIP181.
     * @param node The ENS node to query.
     * @return The associated name.
     */
    function name(bytes32 node) public view returns (string memory) {
        return records[node].name;
    }

    /**
     * Returns the address associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated address.
     */
    function addr(bytes32 node) public view returns (address) {
        return records[node].addr;
    }

    /**
     * Returns the contenthash associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node) public view returns (bytes memory) {
        return records[node].contenthash;
    }

    /**
     * Returns true if the resolver implements the interface specified by the provided hash.
     * @param interfaceID The ID of the interface to check for.
     * @return True if the contract implements the requested interface.
     */
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == ADDR_INTERFACE_ID ||
        interfaceID == NAME_INTERFACE_ID ||
        interfaceID == ABI_INTERFACE_ID ||
        interfaceID == PUBKEY_INTERFACE_ID ||
        interfaceID == TEXT_INTERFACE_ID ||
        interfaceID == CONTENTHASH_INTERFACE_ID ||
        interfaceID == INTERFACE_META_ID;
    }
}

contract EnsReverseRegistrar {

    string constant public ensReverseRegistrarVersion = "2019102500";

   // namehash('addr.reverse')
    bytes32 constant ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    EnsRegistry public ens;
    EnsResolver public defaultResolver;

    /**
     * @dev Constructor
     * @param ensAddr The address of the ENS registry.
     * @param resolverAddr The address of the default reverse resolver.
     */
    constructor(address ensAddr, address resolverAddr) public {
        ens = EnsRegistry(ensAddr);
        defaultResolver = EnsResolver(resolverAddr);
    }

    /**
     * @dev Transfers ownership of the reverse ENS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in ENS.
     * @return The ENS node hash of the reverse record.
     */
    function claim(address owner) public returns (bytes32) {
        return claimWithResolver(owner, address(0));
    }

    /**
     * @dev Transfers ownership of the reverse ENS record associated with the
     *      calling account.
     * @param owner The address to set as the owner of the reverse record in ENS.
     * @param resolver The address of the resolver to set; 0 to leave unchanged.
     * @return The ENS node hash of the reverse record.
     */
    function claimWithResolver(address owner, address resolver) public returns (bytes32) {
        bytes32 label = sha3HexAddress(msg.sender);
        bytes32 node = keccak256(abi.encodePacked(ADDR_REVERSE_NODE, label));
        address currentOwner = ens.owner(node);

        // Update the resolver if required
        if(resolver != address(0) && resolver != address(ens.resolver(node))) {
            // Transfer the name to us first if it's not already
            if(currentOwner != address(this)) {
                ens.setSubnodeOwner(ADDR_REVERSE_NODE, label, address(this));
                currentOwner = address(this);
            }
            ens.setResolver(node, resolver);
        }

        // Update the owner if required
        if(currentOwner != owner) {
            ens.setSubnodeOwner(ADDR_REVERSE_NODE, label, owner);
        }

        return node;
    }

    /**
     * @dev Sets the `name()` record for the reverse ENS record associated with
     * the calling account. First updates the resolver to the default reverse
     * resolver if necessary.
     * @param name The name to set for this address.
     * @return The ENS node hash of the reverse record.
     */
    function setName(string memory name) public returns (bytes32 node) {
        node = claimWithResolver(address(this), address(defaultResolver));
        defaultResolver.setName(node, name);
        return node;
    }

    /**
     * @dev Returns the node hash for a given account's reverse records.
     * @param addr The address to hash
     * @return The ENS node hash.
     */
    function node(address addr) public returns (bytes32 ret) {
        return keccak256(abi.encodePacked(ADDR_REVERSE_NODE, sha3HexAddress(addr)));
    }

    /**
     * @dev An optimised function to compute the sha3 of the lower-case
     *      hexadecimal representation of an Ethereum address.
     * @param addr The address to hash
     * @return The SHA3 hash of the lower-case hexadecimal encoding of the
     *         input address.
     */
    function sha3HexAddress(address addr) private pure returns (bytes32 ret) {
        assembly {
            let lookup := 0x3031323334353637383961626364656600000000000000000000000000000000
            let i := 40

            for { } gt(i, 0) { } {
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
                i := sub(i, 1)
                mstore8(i, byte(and(addr, 0xf), lookup))
                addr := div(addr, 0x10)
            }
            ret := keccak256(0, 40)
        }
    }
}

contract AuthereumEnsResolverStateV1 {

    EnsRegistry ens;
    address public timelockContract;

    mapping (bytes32 => address) public addrs;
    mapping(bytes32 => string) public names;
    mapping(bytes32 => mapping(string => string)) public texts;
    mapping(bytes32 => bytes) public hashes;
}

contract AuthereumEnsResolverState is AuthereumEnsResolverStateV1 {}

contract AuthereumEnsResolver is Managed, AuthereumEnsResolverState {

    string constant public authereumEnsResolverVersion = "2019111500";

    bytes4 constant private INTERFACE_META_ID = 0x01ffc9a7;
    bytes4 constant private ADDR_INTERFACE_ID = 0x3b3b57de;
    bytes4 constant private NAME_INTERFACE_ID = 0x691f3431;
    bytes4 constant private TEXT_INTERFACE_ID = 0x59d1d43c;
    bytes4 constant private CONTENT_HASH_INTERFACE_ID = 0xbc1c58d1;

    event AddrChanged(bytes32 indexed node, address a);
    event NameChanged(bytes32 indexed node, string name);
    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key, string value);
    event ContenthashChanged(bytes32 indexed node, bytes hash);

    /// @dev Constructor
    /// @param _ensAddr The ENS registrar contract
    /// @param _timelockContract Authereum timelock contract address
    constructor(EnsRegistry _ensAddr, address _timelockContract) public {
        ens = _ensAddr;
        timelockContract = _timelockContract;
    }

    /**
     * Setters
     */

    /// @dev Sets the address associated with an ENS node
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param _node The node to update
    /// @param _addr The address to set
    function setAddr(bytes32 _node, address _addr) public onlyManager {
        addrs[_node]= _addr;
        emit AddrChanged(_node, _addr);
    }

    /// @dev Sets the name associated with an ENS node, for reverse records
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param _node The node to update
    /// @param _name The name to set
    function setName(bytes32 _node, string memory _name) public onlyManager {
        names[_node] = _name;
        emit NameChanged(_node, _name);
    }

    /// @dev Sets the text data associated with an ENS node and key
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param node The node to update
    /// @param key The key to set
    /// @param value The text data value to set
    function setText(bytes32 node, string memory key, string memory value) public onlyManager {
        texts[node][key] = value;
        emit TextChanged(node, key, key, value);
    }

    /// @dev Sets the contenthash associated with an ENS node
    /// @notice May only be called by the owner of that node in the ENS registry
    /// @param node The node to update
    /// @param hash The contenthash to set
    function setContenthash(bytes32 node, bytes memory hash) public onlyManager {
        hashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }

    /**
     * Getters
     */

    /// @dev Returns the address associated with an ENS node
    /// @param _node The ENS node to query
    /// @return The associated address
    function addr(bytes32 _node) public view returns (address) {
        return addrs[_node];
    }

    /// @dev Returns the name associated with an ENS node, for reverse records
    /// @notice Defined in EIP181
    /// @param _node The ENS node to query
    /// @return The associated name
    function name(bytes32 _node) public view returns (string memory) {
        return names[_node];
    }

    /// @dev Returns the text data associated with an ENS node and key
    /// @param node The ENS node to query
    /// @param key The text data key to query
    ///@return The associated text data
    function text(bytes32 node, string memory key) public view returns (string memory) {
        return texts[node][key];
    }

    /// @dev Returns the contenthash associated with an ENS node
    /// @param node The ENS node to query
    /// @return The associated contenthash
    function contenthash(bytes32 node) public view returns (bytes memory) {
        return hashes[node];
    }

    /// @dev Returns true if the resolver implements the interface specified by the provided hash
    /// @param _interfaceID The ID of the interface to check for
    /// @return True if the contract implements the requested interface
    function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {
        return _interfaceID == INTERFACE_META_ID ||
        _interfaceID == ADDR_INTERFACE_ID ||
        _interfaceID == NAME_INTERFACE_ID ||
        _interfaceID == TEXT_INTERFACE_ID ||
        _interfaceID == CONTENT_HASH_INTERFACE_ID;
    }
}

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
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

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string memory self) internal pure returns (slice memory) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (uint256(self) & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (uint256(self) & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (uint256(self) & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (uint256(self) & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (uint256(self) & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    /*
     * @dev Returns a slice containing the entire bytes32, interpreted as a
     *      null-terminated utf-8 string.
     * @param self The bytes32 value to convert to a slice.
     * @return A new slice containing the value of the input argument up to the
     *         first null.
     */
    function toSliceB32(bytes32 self) internal pure returns (slice memory ret) {
        // Allocate space for `self` in memory, copy it there, and point ret at it
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice memory self) internal pure returns (slice memory) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice memory self) internal pure returns (string memory) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice memory self) internal pure returns (uint l) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    /*
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
    function empty(slice memory self) internal pure returns (bool) {
        return self._len == 0;
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two slices are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first slice to compare.
     * @param other The second slice to compare.
     * @return The result of the comparison.
     */
    function compare(slice memory self, slice memory other) internal pure returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant bytes and check again
                uint256 mask = uint256(-1); // 0xffff...
                if(shortest < 32) {
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    /*
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
    function equals(slice memory self, slice memory other) internal pure returns (bool) {
        return compare(self, other) == 0;
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice memory self, slice memory rune) internal pure returns (slice memory) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        // Check for truncated codepoints
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice memory self) internal pure returns (slice memory ret) {
        nextRune(self, ret);
    }

    /*
     * @dev Returns the number of the first codepoint in the slice.
     * @param self The slice to operate on.
     * @return The number of the first codepoint in the slice.
     */
    function ord(slice memory self) internal pure returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        // Load the rune into the MSBs of b
        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        // Check for truncated codepoints
        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                // Invalid UTF-8 sequence
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    /*
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
    function keccak(slice memory self) internal pure returns (bytes32 ret) {
        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

    /*
     * @dev Returns true if `self` starts with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function startsWith(slice memory self, slice memory needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    /*
     * @dev If `self` starts with `needle`, `needle` is removed from the
     *      beginning of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function beyond(slice memory self, slice memory needle) internal pure returns (slice memory) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    /*
     * @dev Returns true if the slice ends with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function endsWith(slice memory self, slice memory needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    /*
     * @dev If `self` ends with `needle`, `needle` is removed from the
     *      end of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function until(slice memory self, slice memory needle) internal pure returns (slice memory) {
        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    // Returns the memory address of the first byte after the last occurrence of
    // `needle` in `self`, or the address of `self` if not found.
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := keccak256(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := keccak256(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    /*
     * @dev Modifies `self` to contain everything from the first occurrence of
     *      `needle` to the end of the slice. `self` is set to the empty slice
     *      if `needle` is not found.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function find(slice memory self, slice memory needle) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    /*
     * @dev Modifies `self` to contain the part of the string from the start of
     *      `self` to the end of the first occurrence of `needle`. If `needle`
     *      is not found, `self` is set to the empty slice.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function rfind(slice memory self, slice memory needle) internal pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        split(self, needle, token);
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and `token` to everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function rsplit(slice memory self, slice memory needle, slice memory token) internal pure returns (slice memory) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and returning everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` after the last occurrence of `delim`.
     */
    function rsplit(slice memory self, slice memory needle) internal pure returns (slice memory token) {
        rsplit(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice memory self, slice memory needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
    function contains(slice memory self, slice memory needle) internal pure returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice memory self, slice memory other) internal pure returns (string memory) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    /*
     * @dev Joins an array of slices, using `self` as a delimiter, returning a
     *      newly allocated string.
     * @param self The delimiter to use.
     * @param parts A list of slices to join.
     * @return A newly allocated string containing all the slices in `parts`,
     *         joined with `self`.
     */
    function join(slice memory self, slice[] memory parts) internal pure returns (string memory) {
        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(uint i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}

contract AuthereumEnsManager is Owned {
    using strings for *;

    string constant public authereumEnsManagerVersion = "2020020200";

    // namehash('addr.reverse')
    bytes32 constant public ADDR_REVERSE_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;
    address ensRegistry;

    // The managed root name
    string public rootName;
    // The managed root node
    bytes32 public rootNode;
    // The address of the authereumEnsResolver
    address public authereumEnsResolver;
    // The address of the Authereum factory
    address public authereumFactoryAddress;
    // A mapping of the runtimeCodeHash to creationCodeHash
    mapping(bytes32 => bytes32) public authereumProxyBytecodeHashMapping;

    event RootnodeOwnerChanged(bytes32 indexed rootnode, address indexed newOwner);
    event RootnodeResolverChanged(bytes32 indexed rootnode, address indexed newResolver);
    event RootnodeTTLChanged(bytes32 indexed rootnode, uint64 indexed newTtl);
    event RootnodeTextChanged(bytes32 indexed node, string indexed indexedKey, string key, string value);
    event RootnodeContenthashChanged(bytes32 indexed node, bytes hash);
    event AuthereumEnsResolverChanged(address indexed authereumEnsResolver);
    event AuthereumFactoryAddressChanged(address indexed authereumFactoryAddress);
    event AuthereumProxyBytecodeHashChanged(bytes32 indexed authereumProxyRuntimeCodeHash, bytes32 indexed authereumProxyCreationCodeHash);
    event Registered(address indexed owner, string ens);

    /// @dev Throws if the sender is not the Authereum factory
    modifier onlyAuthereumFactory() {
        require(msg.sender == authereumFactoryAddress, "AEM: Must be sent from the authereumFactoryAddress");
        _;
    }

    /// @dev Constructor that sets the ENS root name and root node to manage
    /// @param _rootName The root name (e.g. authereum.eth)
    /// @param _rootNode The node of the root name (e.g. namehash(authereum.eth))
    /// @param _ensRegistry Public ENS Registry address
    /// @param _authereumEnsResolver Custom Autheruem ENS Resolver address
    constructor(
        string memory _rootName,
        bytes32 _rootNode,
        address _ensRegistry,
        address _authereumEnsResolver
    )
        public
    {
        rootName = _rootName;
        rootNode = _rootNode;
        ensRegistry = _ensRegistry;
        authereumEnsResolver = _authereumEnsResolver;
    }

    /**
     * Canonical ENS
     */

    /// @dev Gets the official ENS registry
    /// @return The official ENS registry address
    function getEnsRegistry() public view returns (EnsRegistry) {
        return EnsRegistry(ensRegistry);
    }

    /// @dev Gets the official ENS reverse registrar
    /// @return The official ENS reverse registrar address
    function getEnsReverseRegistrar() public view returns (EnsReverseRegistrar) {
        return EnsReverseRegistrar(getEnsRegistry().owner(ADDR_REVERSE_NODE));
    }

    /**
     *  Rootnode - Registry
     */

    /// @dev This function is used when the rootnode owner is updated
    /// @param _newOwner The address of the new ENS manager that will manage the root node
    function changeRootnodeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "AEM: Address must not be null");
        getEnsRegistry().setOwner(rootNode, _newOwner);
        emit RootnodeOwnerChanged(rootNode, _newOwner);
    }

    /// @dev This function is used when the rootnode resolver is updated
    /// @param _newResolver The address of the new ENS Resolver that will manage the root node
    function changeRootnodeResolver(address _newResolver) external onlyOwner {
        require(_newResolver != address(0), "AEM: Address must not be null");
        getEnsRegistry().setResolver(rootNode, _newResolver);
        emit RootnodeResolverChanged(rootNode, _newResolver);
    }

    /// @dev This function is used when the rootnode TTL is updated
    /// @param _newTtl The address of the new TTL that will manage the root node
    function changeRootnodeTTL(uint64 _newTtl) external onlyOwner {
        getEnsRegistry().setTTL(rootNode, _newTtl);
        emit RootnodeTTLChanged(rootNode, _newTtl);
    }

    /**
     *  Rootnode - Resolver
     */

    /// @dev This function is used when the rootnode text record is updated
    /// @param _newKey The key of the new text record for the root node
    /// @param _newValue The value of the new text record for the root node
    function changeRootnodeText(string calldata _newKey, string calldata _newValue) external onlyOwner {
        AuthereumEnsResolver(authereumEnsResolver).setText(rootNode, _newKey, _newValue);
        emit RootnodeTextChanged(rootNode, _newKey, _newKey, _newValue);
    }

    /// @dev This function is used when the rootnode contenthash is updated
    /// @param _newHash The new contenthash of the root node
    function changeRootnodeContenthash(bytes calldata _newHash) external onlyOwner {
        AuthereumEnsResolver(authereumEnsResolver).setContenthash(rootNode, _newHash);
        emit RootnodeContenthashChanged(rootNode, _newHash);
    }

    /**
     * State
     */

    /// @dev Lets the owner change the address of the Authereum ENS resolver contract
    /// @param _authereumEnsResolver The address of the Authereun ENS resolver contract
    function changeAuthereumEnsResolver(address _authereumEnsResolver) external onlyOwner {
        require(_authereumEnsResolver != address(0), "AEM: Address must not be null");
        authereumEnsResolver = _authereumEnsResolver;
        emit AuthereumEnsResolverChanged(_authereumEnsResolver);
    }

    /// @dev Lets the owner change the address of the Authereum factory
    /// @param _authereumFactoryAddress The address of the Authereum factory
    function changeAuthereumFactoryAddress(address _authereumFactoryAddress) external onlyOwner {
        require(_authereumFactoryAddress != address(0), "AEM: Address must not be null");
        authereumFactoryAddress = _authereumFactoryAddress;
        emit AuthereumFactoryAddressChanged(authereumFactoryAddress);
    }

    /**
     * Register
     */

    /// @dev Lets the manager assign an ENS subdomain of the root node to a target address
    /// @notice Registers both the forward and reverse ENS
    /// @param _label The subdomain label
    /// @param _owner The owner of the subdomain
    function register(
        string calldata _label,
        address _owner
    )
        external
        onlyAuthereumFactory
    {
        bytes32 labelNode = keccak256(abi.encodePacked(_label));
        bytes32 node = keccak256(abi.encodePacked(rootNode, labelNode));
        address currentOwner = getEnsRegistry().owner(node);
        require(currentOwner == address(0), "AEM: Label is already owned");

        // Forward ENS
        getEnsRegistry().setSubnodeOwner(rootNode, labelNode, address(this));
        getEnsRegistry().setResolver(node, authereumEnsResolver);
        getEnsRegistry().setOwner(node, _owner);
        AuthereumEnsResolver(authereumEnsResolver).setAddr(node, _owner);

        // Reverse ENS
        strings.slice[] memory parts = new strings.slice[](2);
        parts[0] = _label.toSlice();
        parts[1] = rootName.toSlice();
        string memory name = ".".toSlice().join(parts);
        bytes32 reverseNode = EnsReverseRegistrar(getEnsReverseRegistrar()).node(_owner);
        AuthereumEnsResolver(authereumEnsResolver).setName(reverseNode, name);

        emit Registered(_owner, name);
    }

    /**
     *  Public functions
     */

    /// @dev Returns true is a given subnode is available
    /// @param _subnode The target subnode
    /// @return True if the subnode is available
    function isAvailable(bytes32 _subnode) public view returns (bool) {
        bytes32 node = keccak256(abi.encodePacked(rootNode, _subnode));
        address currentOwner = getEnsRegistry().owner(node);
        if(currentOwner == address(0)) {
            return true;
        }
        return false;
    }
}
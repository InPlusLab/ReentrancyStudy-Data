/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

pragma solidity 0.5.8;

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

interface IClock {
  function getTime() view external returns (uint256);
}

contract Clock is IClock {
  function getTime() view public returns (uint256) {
    return block.timestamp;
  }
}

// This registrar allows a set of claimant addresses to alias any subnode to an address.
contract EthvaultENSRegistrar is Clock {
  // The public resolver address can be found as the resolver of the "resolver" top level node
  bytes32 public constant RESOLVER_NODE = keccak256(abi.encodePacked(bytes32(0), keccak256("resolver")));

  // Emitted when a user is registered
  event Registration(address claimant, bytes32 label, address owner, uint256 value);

  ENS public ens;

  // The node corresponding to ethvault.xyz
  bytes32 public rootNode;

  // The addresses that may claim ENS subdomains for the given node
  mapping(address => bool) public isClaimant;

  constructor(ENS _ens, bytes32 _rootNode) public {
    ens = _ens;
    rootNode = _rootNode;

    isClaimant[msg.sender] = true;
  }

  // Only one of the claimants may call a function.
  modifier claimantOnly() {
    if (!isClaimant[msg.sender]) {
      revert("unauthorized - must be from claimant");
    }

    _;
  }

  // Add claimants to the set.
  function addClaimants(address[] calldata claimants) external claimantOnly {
    for (uint i = 0; i < claimants.length; i++) {
      isClaimant[claimants[i]] = true;
    }
  }

  // Remove claimants from the set.
  function removeClaimants(address[] calldata claimants) external claimantOnly {
    for (uint i = 0; i < claimants.length; i++) {
      isClaimant[claimants[i]] = false;
    }
  }

  // Compute the namehash from the label and the root node.
  function namehash(bytes32 label) view public returns (bytes32) {
    return keccak256(abi.encodePacked(rootNode, label));
  }

  // Get the data that the user should sign to release a name.
  function getReleaseSignData(bytes32 label, uint256 expirationTimestamp) pure public returns (bytes32) {
    return keccak256(abi.encodePacked(label, expirationTimestamp));
  }

  /**
   * @dev Recover signer address from a message by using their signature
   * @param _hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param _sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 _hash, bytes memory _sig)
    internal
    pure
    returns (address)
  {
    bytes32 r;
    bytes32 s;
    uint8 v;

    // Check the signature length
    if (_sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    // ecrecover takes the signature parameters, and the only way to get them
    // currently is to use assembly.
    // solium-disable-next-line security/no-inline-assembly
    assembly {
      r := mload(add(_sig, 32))
      s := mload(add(_sig, 64))
      v := byte(0, mload(add(_sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      // solium-disable-next-line arg-overflow
      return ecrecover(_hash, v, r, s);
    }
  }

  /**
   * toEthSignedMessageHash
   * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
   * and hash the result
   */
  function toEthSignedMessageHash(bytes32 _hash)
    internal
    pure
    returns (bytes32)
  {
    // 32 is the length in bytes of hash,
    // enforced by the type signature above
    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
    );
  }

  // Allow a subnode to be released given the user's signature. Anyone can perform this operation as long as the
  // signature has not expired.
  function release(bytes32 label, uint256 expirationTimestamp, bytes calldata signature) external {
    bytes32 subnode = namehash(label);

    address currentOwner = ens.owner(subnode);

    if (currentOwner == address(0)) {
      // No-op, just return.
      return;
    }

    address signer = recover(
      toEthSignedMessageHash(getReleaseSignData(label, expirationTimestamp)),
      signature
    );

    if (signer == address(0)) {
      revert("invalid signature");
    }

    if (signer != currentOwner) {
      revert("signature is not from current owner");
    }

    if (expirationTimestamp < getTime()) {
      revert("the signature has expired");
    }

    ens.setSubnodeOwner(rootNode, label, address(0));
  }

  // Return the public resolver. This is called to get the public resolver to use during registration.
  function getPublicResolver() view public returns (Resolver) {
    address resolverAddr = ens.resolver(RESOLVER_NODE);
    
    if (resolverAddr == address(0)) {
      revert("failed to get resolver address");
    }

    Resolver resolver = Resolver(resolverAddr);

    address publicResolver = resolver.addr(RESOLVER_NODE);
    if (publicResolver == address(0)) {
      revert("resolver had address zero for node");
    }

    return Resolver(publicResolver);
  }

  /**
   * Register a subdomain name, sets the resolver, updates the resolver, and sets the address of the resolver to the
   * new owner. Also transfers any additional value to each address.
   * @param labels The hashes of the label to register
   * @param owners The addresses of the new owners
   * @param values The WEI values to send to each address
   */
  function register(bytes32[] calldata labels, address payable[] calldata owners, uint256[] calldata values) external payable claimantOnly {
    if (labels.length != owners.length || owners.length != values.length) {
      revert("must pass the same number of labels and owners");
    }

    uint256 dispersedTotal = 0;

    for (uint i = 0; i < owners.length; i++) {
      bytes32 label = labels[i];
      address payable owner = owners[i];
      uint256 value = values[i];

      // Compute the subnode hash
      bytes32 subnode = namehash(label);

      // Get the current owner of this subnode
      address currentOwner = ens.owner(subnode);

      // Prevent overwriting ownership with a different address
      if (currentOwner != address(0) && currentOwner != owner) {
        revert("the label owner may not be changed");
      }

      // Skip if the current owner is already the owner
      if (currentOwner == owner) {
        continue;
      }

      Resolver publicResolver = getPublicResolver();

      // First set it to this, so we can update it.
      ens.setSubnodeOwner(rootNode, label, address(this));

      // Set the resolver for the subnode to the public resolver
      ens.setResolver(subnode, address(publicResolver));

      // Set the address to the owner in the public resolver
      publicResolver.setAddr(subnode, owner);

      // Finally pass ownership to the new owner.
      ens.setSubnodeOwner(rootNode, label, owner);

      if (value > 0) {
        dispersedTotal = dispersedTotal + value;
        owner.transfer(value);
      }

      emit Registration(msg.sender, label, owner, value);
    }

    if (dispersedTotal < msg.value) {
      msg.sender.transfer(msg.value - dispersedTotal);
    }
  }

}
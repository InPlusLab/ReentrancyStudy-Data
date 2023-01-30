/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

/*
 ENS Contanthash resolver (EIP-1577) wich may be updated with signatures from contenthash-signer-ens


 Copyright (c) Ulf Bartel

 Public repository:
 https://github.com/berlincode/contenthash-signer-ens

 License: MIT

 Contact:
 elastic.code@gmail.com

 Version 4.0.0

 This contract acts as a ens resolver.
 Implements contenthash field for ENS (EIP 1577) (https://eips.ethereum.org/EIPS/eip-1577).
*/

pragma solidity 0.5.10;
pragma experimental ABIEncoderV2;

/*
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
*/


contract ResolverContenthashSignerENS {

    /* public constant contractVersion */
    uint64 public constant contractVersion = (
        (0 << 32) + /* major */
        (5 << 16) + /* minor */
        0 /* bugfix */
    );

    bytes4 constant CONTENTHASH_INTERFACE_ID = 0xbc1c58d1;

    event ContenthashChanged(bytes32 indexed node, bytes hash);

    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct Record {
        uint64 version;
        bytes contenthash;
    }

    address signer; /* signer address */

    mapping (bytes32 => Record) records;

    /**
     * Constructor.
     * @param signerAddr The signer address.
     */
    constructor(address signerAddr) public {
        signer = signerAddr;
    }

    /**
     * Sets the contenthash associated with an ENS node.
     * May only be called by the owner of that node in the ENS registry.
     * @param node The node to update.
     * @param hash The contenthash to set
     */
    /*
    function setContenthash(bytes32 node, bytes calldata hash) external {
        require(
            false,
            "Function call not supported"
        );
    }
    */

    /**
     * Returns the contenthash associated with an ENS node.
     * @param node The ENS node to query.
     * @return The associated contenthash.
     */
    function contenthash(bytes32 node) external view returns (bytes memory) {
        return records[node].contenthash;
    }

    /**
     * Returns true if the resolver implements the interface specified by the provided hash.
     * @param interfaceID The ID of the interface to check for.
     * @return True if the contract implements the requested interface.
     */
    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {
        return interfaceID == CONTENTHASH_INTERFACE_ID;
    }

    /**
     * Sets the contenthash associated with an ENS node using a prebuild signature.
     * May be called by anyone with a valid signature.
     * @param node The node to update.
     * @param hash The contenthash to set
     * @param version The version (which is part of the signature)
     * @param signature The signature over the keccak256(hash, version)
     */
    function setContenthashBySignature (
        bytes32 node,
        bytes memory hash,
        uint64 version,
        Signature memory signature
    ) public
    {
        require(
            signer == verify(
                keccak256(
                    abi.encodePacked(
                        hash,
                        version
                    )
                ),
                signature
            ),
            "Invalid signature"
        );

        // update only if new version is higher than current version
        if (version > records[node].version) {
            records[node].contenthash = hash;
            records[node].version = version;
            emit ContenthashChanged(node, hash);
        }
    }

    /* internal functions */

    function verify(
        bytes32 _message,
        Signature memory signature
    ) internal pure returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(
            abi.encodePacked(
                prefix,
                _message
            )
        );
        return ecrecover(
            prefixedHash,
            signature.v,
            signature.r,
            signature.s
        );
    }

}
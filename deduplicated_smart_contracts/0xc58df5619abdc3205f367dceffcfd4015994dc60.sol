/**

 *Submitted for verification at Etherscan.io on 2018-10-23

*/



pragma solidity ^0.4.18;



interface AbstractENS {

    function owner(bytes32 _node) public constant returns (address);

    function resolver(bytes32 _node) public constant returns (address);

    function ttl(bytes32 _node) public constant returns (uint64);

    function setOwner(bytes32 _node, address _owner) public;

    function setSubnodeOwner(bytes32 _node, bytes32 label, address _owner) public;

    function setResolver(bytes32 _node, address _resolver) public;

    function setTTL(bytes32 _node, uint64 _ttl) public;



    // Logged when the owner of a node assigns a new owner to a subnode.

    event NewOwner(bytes32 indexed _node, bytes32 indexed _label, address _owner);



    // Logged when the owner of a node transfers ownership to a new account.

    event Transfer(bytes32 indexed _node, address _owner);



    // Logged when the resolver for a node changes.

    event NewResolver(bytes32 indexed _node, address _resolver);



    // Logged when the TTL of a node changes

    event NewTTL(bytes32 indexed _node, uint64 _ttl);

}



pragma solidity ^0.4.0;



/**

 * A simple resolver anyone can use; only allows the owner of a node to set its

 * address.

 */

contract PublicResolver {

    bytes4 constant INTERFACE_META_ID = 0x01ffc9a7;

    bytes4 constant ADDR_INTERFACE_ID = 0x3b3b57de;

    bytes4 constant CONTENT_INTERFACE_ID = 0xd8389dc5;

    bytes4 constant NAME_INTERFACE_ID = 0x691f3431;

    bytes4 constant ABI_INTERFACE_ID = 0x2203ab56;

    bytes4 constant PUBKEY_INTERFACE_ID = 0xc8690233;

    bytes4 constant TEXT_INTERFACE_ID = 0x59d1d43c;



    event AddrChanged(bytes32 indexed node, address a);

    event ContentChanged(bytes32 indexed node, bytes32 hash);

    event NameChanged(bytes32 indexed node, string name);

    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);

    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);

    event TextChanged(bytes32 indexed node, string indexed indexedKey, string key);



    struct PublicKey {

        bytes32 x;

        bytes32 y;

    }



    struct Record {

        address addr;

        bytes32 content;

        string name;

        PublicKey pubkey;

        mapping(string=>string) text;

        mapping(uint256=>bytes) abis;

    }



    AbstractENS ens;

    mapping(bytes32=>Record) records;



    modifier only_owner(bytes32 node) {

        if (ens.owner(node) != msg.sender) throw;

        _;

    }



    /**

     * Constructor.

     * @param ensAddr The ENS registrar contract.

     */

    function PublicResolver(AbstractENS ensAddr) public {

        ens = ensAddr;

    }



    /**

     * Returns true if the resolver implements the interface specified by the provided hash.

     * @param interfaceID The ID of the interface to check for.

     * @return True if the contract implements the requested interface.

     */

    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {

        return interfaceID == ADDR_INTERFACE_ID ||

               interfaceID == CONTENT_INTERFACE_ID ||

               interfaceID == NAME_INTERFACE_ID ||

               interfaceID == ABI_INTERFACE_ID ||

               interfaceID == PUBKEY_INTERFACE_ID ||

               interfaceID == TEXT_INTERFACE_ID ||

               interfaceID == INTERFACE_META_ID;

    }



    /**

     * Returns the address associated with an ENS node.

     * @param node The ENS node to query.

     * @return The associated address.

     */

    function addr(bytes32 node) public constant returns (address ret) {

        ret = records[node].addr;

    }



    /**

     * Sets the address associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param addr The address to set.

     */

    function setAddr(bytes32 node, address addr) only_owner(node) public {

        records[node].addr = addr;

        AddrChanged(node, addr);

    }



    /**

     * Returns the content hash associated with an ENS node.

     * Note that this resource type is not standardized, and will likely change

     * in future to a resource type based on multihash.

     * @param node The ENS node to query.

     * @return The associated content hash.

     */

    function content(bytes32 node) public constant returns (bytes32 ret) {

        ret = records[node].content;

    }



    /**

     * Sets the content hash associated with an ENS node.

     * May only be called by the owner of that node in the ENS registry.

     * Note that this resource type is not standardized, and will likely change

     * in future to a resource type based on multihash.

     * @param node The node to update.

     * @param hash The content hash to set

     */

    function setContent(bytes32 node, bytes32 hash) only_owner(node) public {

        records[node].content = hash;

        ContentChanged(node, hash);

    }



    /**

     * Returns the name associated with an ENS node, for reverse records.

     * Defined in EIP181.

     * @param node The ENS node to query.

     * @return The associated name.

     */

    function name(bytes32 node) public constant returns (string ret) {

        ret = records[node].name;

    }



    /**

     * Sets the name associated with an ENS node, for reverse records.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param name The name to set.

     */

    function setName(bytes32 node, string name) only_owner(node) public {

        records[node].name = name;

        NameChanged(node, name);

    }



    /**

     * Returns the ABI associated with an ENS node.

     * Defined in EIP205.

     * @param node The ENS node to query

     * @param contentTypes A bitwise OR of the ABI formats accepted by the caller.

     * @return contentType The content type of the return value

     * @return data The ABI data

     */

    function ABI(bytes32 node, uint256 contentTypes) public constant returns (uint256 contentType, bytes data) {

        var record = records[node];

        for(contentType = 1; contentType <= contentTypes; contentType <<= 1) {

            if ((contentType & contentTypes) != 0 && record.abis[contentType].length > 0) {

                data = record.abis[contentType];

                return;

            }

        }

        contentType = 0;

    }



    /**

     * Sets the ABI associated with an ENS node.

     * Nodes may have one ABI of each content type. To remove an ABI, set it to

     * the empty string.

     * @param node The node to update.

     * @param contentType The content type of the ABI

     * @param data The ABI data.

     */

    function setABI(bytes32 node, uint256 contentType, bytes data) only_owner(node) public {

        // Content types must be powers of 2

        if (((contentType - 1) & contentType) != 0) throw;



        records[node].abis[contentType] = data;

        ABIChanged(node, contentType);

    }



    /**

     * Returns the SECP256k1 public key associated with an ENS node.

     * Defined in EIP 619.

     * @param node The ENS node to query

     * @return x, y the X and Y coordinates of the curve point for the public key.

     */

    function pubkey(bytes32 node) public constant returns (bytes32 x, bytes32 y) {

        return (records[node].pubkey.x, records[node].pubkey.y);

    }



    /**

     * Sets the SECP256k1 public key associated with an ENS node.

     * @param node The ENS node to query

     * @param x the X coordinate of the curve point for the public key.

     * @param y the Y coordinate of the curve point for the public key.

     */

    function setPubkey(bytes32 node, bytes32 x, bytes32 y) only_owner(node) public {

        records[node].pubkey = PublicKey(x, y);

        PubkeyChanged(node, x, y);

    }



    /**

     * Returns the text data associated with an ENS node and key.

     * @param node The ENS node to query.

     * @param key The text data key to query.

     * @return The associated text data.

     */

    function text(bytes32 node, string key) public constant returns (string ret) {

        ret = records[node].text[key];

    }



    /**

     * Sets the text data associated with an ENS node and key.

     * May only be called by the owner of that node in the ENS registry.

     * @param node The node to update.

     * @param key The key to set.

     * @param value The text data value to set.

     */

    function setText(bytes32 node, string key, string value) only_owner(node) public {

        records[node].text[key] = value;

        TextChanged(node, key, key);

    }

}



/*

 * SPDX-License-Identitifer:    MIT

 */



pragma solidity ^0.4.24;





contract ENSConstants {

    bytes32 constant public ENS_ROOT = bytes32(0);

    bytes32 constant public ETH_TLD_LABEL = keccak256("eth");

    bytes32 constant public ETH_TLD_NODE = keccak256(abi.encodePacked(ENS_ROOT, ETH_TLD_LABEL));

    bytes32 constant public PUBLIC_RESOLVER_LABEL = keccak256("resolver");

    bytes32 constant public PUBLIC_RESOLVER_NODE = keccak256(abi.encodePacked(ETH_TLD_NODE, PUBLIC_RESOLVER_LABEL));

    address constant public PORTAL_NETWORK_RESOLVER = 0x1da022710dF5002339274AaDEe8D58218e9D6AB5;

}





contract dwebregistry is ENSConstants {

    

    AbstractENS public ens = AbstractENS(0x314159265dD8dbb310642f98f50C066173C1259b);

    event NewDWeb(bytes32 indexed node, string label, string hash);



    function createDWeb(bytes32 _rootNode, string _label, string dnslink, bytes32 content) external returns (bytes32 node) {

        return _createDWeb(_rootNode, _label, msg.sender, dnslink, content);

    }



    function _createDWeb(bytes32 _rootNode, string _label, address _owner, string dnslink, bytes32 content) internal returns (bytes32 node) {

        require(ens.owner(_rootNode) == address(this));



        node = getNodeForLabel(_rootNode, getKeccak256Label(_label));

        require(ens.owner(node) == address(0)); // avoid name reset

        

        ens.setSubnodeOwner(_rootNode, getKeccak256Label(_label), address(this));

        

        address publicResolver = getAddr(PUBLIC_RESOLVER_NODE);

        ens.setResolver(node, publicResolver);



        PublicResolver(publicResolver).setText(node,'dnslink', dnslink);

        PublicResolver(publicResolver).setContent(node, content);

        

        ens.setSubnodeOwner(_rootNode, getKeccak256Label(_label), _owner);



        emit NewDWeb(node, _label, dnslink);



        return node;

    }

    

    function getAddr(bytes32 node) internal view returns (address) {

        address resolver = ens.resolver(node);

        return PublicResolver(resolver).addr(node);

    }

    

    function getNodeForLabel(bytes32 _rootNode, bytes32 _label) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_rootNode, _label));

    }

    

    function getKeccak256Label(string _label) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked(_label));

    }



}
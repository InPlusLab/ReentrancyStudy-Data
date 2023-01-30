/**
 *Submitted for verification at Etherscan.io on 2019-07-15
*/

pragma solidity ^0.5;

contract owned {
    address payable public owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract SattResolver is owned {
    
    struct PublicKey {
        bytes32 x;
        bytes32 y;
    }

    mapping(bytes32=>address) addresses;
    mapping(bytes32=>string) names;
    mapping(bytes32=>mapping(uint256=>bytes)) abis;
    mapping(bytes32=>bytes) hashes;
    mapping(bytes32=>PublicKey) pubkeys;
    mapping(bytes32=>mapping(string=>string)) texts;
    
    event AddrChanged(bytes32 indexed node, address a);
    event NameChanged(bytes32 indexed node, string name);
    event ContenthashChanged(bytes32 indexed node, bytes hash);
    event ABIChanged(bytes32 indexed node, uint256 indexed contentType);
    event PubkeyChanged(bytes32 indexed node, bytes32 x, bytes32 y);
    event TextChanged(bytes32 indexed node, string indexedKey, string key);
    
    function supportsInterface(bytes4 interfaceID) public pure returns (bool) {
        return interfaceID == 0x3b3b57de || interfaceID == 0x01ffc9a7 || interfaceID == 0x691f3431 || interfaceID == 0x2203ab56 || interfaceID == 0xc8690233 || interfaceID == 0x59d1d43c || interfaceID == 0xbc1c58d1;
    }

    function addr(bytes32 node) external view returns (address)
    {
        return addresses[node];
    }
    
    function setAddr(bytes32 node, address ad) external onlyOwner {
        addresses[node] = ad;
        emit AddrChanged(node, ad);
    }
    
    function name(bytes32 node) external view returns (string memory) {
        return names[node];
    }
    
    function setName(bytes32 node, string calldata nme) external onlyOwner {
         emit NameChanged(node, nme);
    }
    
    function contenthash(bytes32 node) external view returns (bytes memory) {
        return hashes[node];
    }
    
    function setContenthash(bytes32 node, bytes calldata hash) external onlyOwner {
        hashes[node] = hash;
        emit ContenthashChanged(node, hash);
    }
    
    function ABI(bytes32 node, uint256 contentTypes) external view returns (uint256, bytes memory) {
         mapping(uint256=>bytes) storage abiset = abis[node];

        for (uint256 contentType = 1; contentType <= contentTypes; contentType <<= 1) {
            if ((contentType & contentTypes) != 0 && abiset[contentType].length > 0) {
                return (contentType, abiset[contentType]);
            }
        }

        return (0, bytes(""));
    }
    
    function setABI(bytes32 node, uint256 contentType, bytes calldata data) external onlyOwner {
        require(((contentType - 1) & contentType) == 0);

        abis[node][contentType] = data;
        emit ABIChanged(node, contentType);
    }
    
    function pubkey(bytes32 node) external view returns (bytes32 x, bytes32 y) {
        return (pubkeys[node].x, pubkeys[node].y);
    }
    
    function setPubkey(bytes32 node, bytes32 x, bytes32 y) external onlyOwner {
        pubkeys[node] = PublicKey(x, y);
        emit PubkeyChanged(node, x, y);
    }
    
    function text(bytes32 node, string calldata key) external view returns (string memory) {
        return texts[node][key];
    }
    
    function setText(bytes32 node, string calldata key, string calldata value) external onlyOwner {
        texts[node][key] = value;
        emit TextChanged(node, key, key);
    }
}
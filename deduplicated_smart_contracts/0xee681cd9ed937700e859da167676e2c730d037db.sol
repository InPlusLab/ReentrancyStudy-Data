/**
 *Submitted for verification at Etherscan.io on 2020-04-27
*/

// File: akap/contracts/IAKAP.sol

// Copyright (C) 2019  Christian Felde
// Copyright (C) 2019  Mohamed Elshami

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

pragma solidity ^0.5.0;

/**
 * @title  Interface for AKA Protocol Registry (akap.me)
 *
 * @author Christian Felde
 * @author Mohamed Elshami
 *
 * @notice This interface defines basic meta data operations in addition to hashOf and claim functions on AKAP nodes.
 * @dev    Functionality related to the ERC-721 nature of nodes also available on AKAP, like transferFrom(..), etc.
 */
contract IAKAP {
    enum ClaimCase {RECLAIM, NEW, TRANSFER}
    enum NodeAttribute {EXPIRY, SEE_ALSO, SEE_ADDRESS, NODE_BODY, TOKEN_URI}

    event Claim(address indexed sender, uint indexed nodeId, uint indexed parentId, bytes label, ClaimCase claimCase);
    event AttributeChanged(address indexed sender, uint indexed nodeId, NodeAttribute attribute);

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Calculate the hash of a parentId and node label.
     *
     * @param parentId Hash value of parent ID
     * @param label Label of node
     * @return Hash ID of node
     */
    function hashOf(uint parentId, bytes memory label) public pure returns (uint id);

    /**
     * @dev Claim or reclaim a node identified by the given parent ID hash and node label.
     *
     * There are 4 potential return value outcomes:
     *
     * 0: No action taken. This is the default if msg.sender does not have permission to act on the specified node.
     * 1: An existing node already owned by msg.sender was reclaimed.
     * 2: Node did not previously exist and is now minted and allocated to msg.sender.
     * 3: An existing node already exist but was expired. Node ownership transferred to msg.sender.
     *
     * If msg.sender is not the owner but is instead approved "spender" of node, the same logic applies. Only on
     * case 2 and 3 does msg.sender become owner of the node. On case 1 only the expiry is updated.
     *
     * Whenever the return value is non-zero, the expiry of the node has been set to 52 weeks into the future.
     *
     * @param parentId Hash value of parent ID
     * @param label Label of node
     * @return Returns one of the above 4 outcomes
     */
    function claim(uint parentId, bytes calldata label) external returns (uint status);

    /**
     * @dev Returns true if nodeId exists.
     *
     * @param nodeId Node hash ID
     * @return True if node exists
     */
    function exists(uint nodeId) external view returns (bool);

    /**
     * @dev Returns whether msg.sender can transfer, claim or operate on a given node ID.
     *
     * @param nodeId Node hash ID
     * @return bool True if approved or owner
     */
    function isApprovedOrOwner(uint nodeId) external view returns (bool);

    /**
     * @dev Gets the owner of the specified node ID.
     *
     * @param tokenId Node hash ID
     * @return address Node owner address
     */
    function ownerOf(uint256 tokenId) public view returns (address);

    /**
     * @dev Return parent hash ID for given node ID.
     *
     * @param nodeId Node hash ID
     * @return Parent hash ID
     */
    function parentOf(uint nodeId) external view returns (uint);

    /**
     * @dev Return expiry timestamp for given node ID.
     *
     * @param nodeId Node hash ID
     * @return Expiry timestamp as seconds since unix epoch
     */
    function expiryOf(uint nodeId) external view returns (uint);

    /**
     * @dev Return "see also" value for given node ID.
     *
     * @param nodeId Node hash ID
     * @return "See also" value
     */
    function seeAlso(uint nodeId) external view returns (uint);

    /**
     * @dev Return "see address" value for given node ID.
     *
     * @param nodeId Node hash ID
     * @return "See address" value
     */
    function seeAddress(uint nodeId) external view returns (address);

    /**
     * @dev Return "node body" value for given node ID.
     *
     * @param nodeId Node hash ID
     * @return "Node body" value
     */
    function nodeBody(uint nodeId) external view returns (bytes memory);

    /**
     * @dev Return "token URI" value for given node ID.
     *
     * @param tokenId Node hash ID
     * @return "Token URI" value
     */
    function tokenURI(uint256 tokenId) external view returns (string memory);

    /**
     * @dev Will immediately expire node on given node ID.
     *
     * An expired node will continue to function as any other node,
     * but is now available to be claimed by a new owner.
     *
     * @param nodeId Node hash ID
     */
    function expireNode(uint nodeId) external;

    /**
     * @dev Set "see also" value on given node ID.
     *
     * @param nodeId Node hash ID
     * @param value New "see also" value
     */
    function setSeeAlso(uint nodeId, uint value) external;

    /**
     * @dev Set "see address" value on given node ID.
     *
     * @param nodeId Node hash ID
     * @param value New "see address" value
     */
    function setSeeAddress(uint nodeId, address value) external;

    /**
     * @dev Set "node body" value on given node ID.
     *
     * @param nodeId Node hash ID
     * @param value New "node body" value
     */
    function setNodeBody(uint nodeId, bytes calldata value) external;

    /**
     * @dev Set "token URI" value on given node ID.
     *
     * @param nodeId Node hash ID
     * @param uri New "token URI" value
     */
    function setTokenURI(uint nodeId, string calldata uri) external;

    /**
     * @dev Approves another address to transfer the given token ID
     *
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     *
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public;

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     *
     * Reverts if the token ID does not exist.
     *
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address);

    /**
     * @dev Sets or unsets the approval of a given operator
     *
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     *
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public;

    /**
     * @dev Tells whether an operator is approved by a given owner.
     *
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     *
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     *
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public;

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     *
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     *
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     *
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     *
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public;
}

// File: @openzeppelin/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

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

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol

pragma solidity ^0.5.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     *
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either {approve} or {setApprovalForAll}.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either {approve} or {setApprovalForAll}.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: akap-utils/contracts/domain/IDomainManager.sol

// Copyright (C) 2020  Christian Felde

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

pragma solidity ^0.5.0;



contract IDomainManager {
    function akap() public view returns (IAKAP);

    function erc721() public view returns (IERC721);

    function domainParent() public view returns (uint);

    function domainLabel() public view returns (bytes memory);

    function domain() public view returns (uint);

    function setApprovalForAll(address to, bool approved) public;

    function claim(bytes memory label) public returns (uint status);

    function claim(uint parentId, bytes memory label) public returns (uint);

    function reclaim() public returns (uint);
}

// File: akap-utils/contracts/upgradable/AkaProxy.sol

// Copyright (C) 2020  Christian Felde

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at

// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

pragma solidity ^0.5.0;



contract AkaProxy {
    IDomainManager public dm;
    IAKAP public akap;
    uint public rootPtr;

    constructor(address _dmAddress, uint _rootPtr) public {
        dm = IDomainManager(_dmAddress);
        akap = dm.akap();
        rootPtr = _rootPtr;

        require(akap.exists(rootPtr), "AkaProxy: No root node");
    }

    function () payable external {
        address implementationAddress = akap.seeAddress(rootPtr);
        require(implementationAddress != address(0), "AkaProxy: No root node address");

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, implementationAddress, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
}
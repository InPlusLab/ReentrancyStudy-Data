/**
 *Submitted for verification at Etherscan.io on 2021-09-02
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface MapContract {
    function discoverMap(uint256 tokenId) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}


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
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract MultiMap is IERC721Receiver {
    
    
    MapContract _lootContract = MapContract(0xD81f156bBF7043a22d4cE97C0E8ca11d3f4FB3cC);
    
    function getMultiLoot(uint256 numberToMint) public {
    
        uint256 mintedAmount = 0;
        
        for (uint i = 0; i < 9751; i++) {
            if (mintedAmount >= numberToMint) {
                break;
            }
            try _lootContract.discoverMap(i) {
                _lootContract.safeTransferFrom(address(this), msg.sender, i);
                mintedAmount++;
            } catch {}
        }
    }
    
     function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
    
    
}
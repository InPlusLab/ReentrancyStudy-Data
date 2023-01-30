/**
 *Submitted for verification at Etherscan.io on 2020-11-30
*/

/*
¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨[      ¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨[   ¨€¨€¨€¨[¨€¨€¨[¨€¨€¨€¨[   ¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨[          ¨€¨€¨€¨€¨€¨€¨[ 
¨€¨€¨X¨T¨T¨T¨T¨a¨€¨€¨U     ¨€¨€¨X¨T¨T¨€¨€¨[¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨U¨€¨€¨U¨€¨€¨€¨€¨[  ¨€¨€¨U¨€¨€¨X¨T¨T¨T¨T¨a         ¨€¨€¨X¨T¨T¨T¨€¨€¨[
¨€¨€¨€¨€¨€¨[  ¨€¨€¨U     ¨€¨€¨€¨€¨€¨€¨€¨U¨€¨€¨X¨€¨€¨€¨€¨X¨€¨€¨U¨€¨€¨U¨€¨€¨X¨€¨€¨[ ¨€¨€¨U¨€¨€¨U  ¨€¨€¨€¨[        ¨€¨€¨U   ¨€¨€¨U
¨€¨€¨X¨T¨T¨a  ¨€¨€¨U     ¨€¨€¨X¨T¨T¨€¨€¨U¨€¨€¨U¨^¨€¨€¨X¨a¨€¨€¨U¨€¨€¨U¨€¨€¨U¨^¨€¨€¨[¨€¨€¨U¨€¨€¨U   ¨€¨€¨U        ¨€¨€¨U   ¨€¨€¨U
¨€¨€¨U     ¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨U  ¨€¨€¨U¨€¨€¨U ¨^¨T¨a ¨€¨€¨U¨€¨€¨U¨€¨€¨U ¨^¨€¨€¨€¨€¨U¨^¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨€¨€¨€¨€¨€¨[¨^¨€¨€¨€¨€¨€¨€¨X¨a
¨^¨T¨a     ¨^¨T¨T¨T¨T¨T¨T¨a¨^¨T¨a  ¨^¨T¨a¨^¨T¨a     ¨^¨T¨a¨^¨T¨a¨^¨T¨a  ¨^¨T¨T¨T¨a ¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨T¨T¨T¨T¨T¨a ¨^¨T¨T¨T¨T¨T¨a 
        ¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨[  ¨€¨€¨€¨€¨€¨€¨[ ¨€¨€¨€¨€¨€¨€¨[                                  
        ¨€¨€¨X¨T¨T¨€¨€¨[¨€¨€¨X¨T¨T¨€¨€¨[¨€¨€¨X¨T¨T¨T¨€¨€¨[¨€¨€¨X¨T¨T¨€¨€¨[                                 
        ¨€¨€¨U  ¨€¨€¨U¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨U   ¨€¨€¨U¨€¨€¨€¨€¨€¨€¨X¨a                                 
        ¨€¨€¨U  ¨€¨€¨U¨€¨€¨X¨T¨T¨€¨€¨[¨€¨€¨U   ¨€¨€¨U¨€¨€¨X¨T¨T¨T¨a                                  
¨€¨€¨€¨€¨€¨€¨€¨[¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨U  ¨€¨€¨U¨^¨€¨€¨€¨€¨€¨€¨X¨a¨€¨€¨U                                      
¨^¨T¨T¨T¨T¨T¨T¨a¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨a  ¨^¨T¨a ¨^¨T¨T¨T¨T¨T¨a ¨^¨T¨a
// SPDX-License-Identifier: MIT
*/
pragma solidity 0.7.5;

interface IERC20TransferFrom { // interface for erc20 token `transferFrom()`
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC721ListingTransferFrom { // brief interface for erc721 token listing
    function ownerOf(uint256 tokenId) external view returns (address);
    function tokenByIndex(uint256 index) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract FLAMING_O_DROP { 
    address public FLAMING_O = 0xc7886c91fF20dE17c9161666202b8D8953D03BBD;
    uint256 public version = 1;
    
    function dropERC20(address token, uint256 amount) external { // drop sum token amount evenly on FL_O holders
        IERC721ListingTransferFrom fl_o = IERC721ListingTransferFrom(FLAMING_O);
        uint256 count;
        uint256 length = fl_o.totalSupply();
        
        for (uint256 i = 0; i < length; i++) {
            IERC20TransferFrom(token).transferFrom(msg.sender, fl_o.ownerOf(fl_o.tokenByIndex(count)), amount / length);
            count++;
        }
    }
    
    function dropERC721(address token) external { // drop parallel NFT series on FL_O holders
        IERC721ListingTransferFrom fl_o = IERC721ListingTransferFrom(FLAMING_O);
        uint256 count;
        uint256 length = fl_o.totalSupply();
        
        for (uint256 i = 0; i < length; i++) {
            IERC721ListingTransferFrom(token).transferFrom(msg.sender, fl_o.ownerOf(fl_o.tokenByIndex(count)), IERC721ListingTransferFrom(token).tokenByIndex(count));
            count++;
        }
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-12-01
*/

/*
���������������[�����[      �����������[ �������[   �������[�����[�������[   �����[ �������������[          �������������[ 
�����X�T�T�T�T�a�����U     �����X�T�T�����[���������[ ���������U�����U���������[  �����U�����X�T�T�T�T�a         �����X�T�T�T�����[
�����������[  �����U     ���������������U�����X���������X�����U�����U�����X�����[ �����U�����U  �������[        �����U   �����U
�����X�T�T�a  �����U     �����X�T�T�����U�����U�^�����X�a�����U�����U�����U�^�����[�����U�����U   �����U        �����U   �����U
�����U     ���������������[�����U  �����U�����U �^�T�a �����U�����U�����U �^���������U�^�������������X�a���������������[�^�������������X�a
�^�T�a     �^�T�T�T�T�T�T�a�^�T�a  �^�T�a�^�T�a     �^�T�a�^�T�a�^�T�a  �^�T�T�T�a �^�T�T�T�T�T�a �^�T�T�T�T�T�T�a �^�T�T�T�T�T�a 
        �������������[ �������������[  �������������[ �������������[                                  
        �����X�T�T�����[�����X�T�T�����[�����X�T�T�T�����[�����X�T�T�����[                                 
        �����U  �����U�������������X�a�����U   �����U�������������X�a                                 
        �����U  �����U�����X�T�T�����[�����U   �����U�����X�T�T�T�a                                  
���������������[�������������X�a�����U  �����U�^�������������X�a�����U                                      
�^�T�T�T�T�T�T�a�^�T�T�T�T�T�a �^�T�a  �^�T�a �^�T�T�T�T�T�a �^�T�a
// SPDX-License-Identifier: MIT
*/
pragma solidity 0.7.5;

interface IERC20TransferFrom { // interface for erc20 token `transferFrom()`
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

interface IERC721TransferFrom { // interface for erc721 token `transferFrom()`
    function transferFrom(address from, address to, uint256 tokenId) external;
}

interface IFL_O {
    function ownerOf(uint256 tokenId) external view returns (address);
    function totalSupply() external view returns (uint256);
}

contract FLAMING_O_DROP {
    address public FLAMING_O = 0xc7886c91fF20dE17c9161666202b8D8953D03BBD;
    
    function dropERC20(address token, uint256 amount) external { // drop token amount evenly on FL_O holders
        IFL_O FL_O = IFL_O(FLAMING_O);
        uint256 count = 1;
        uint256 length = FL_O.totalSupply();
        
        for (uint256 i = 0; i < length; i++) {
            IERC721TransferFrom(token).transferFrom(msg.sender, FL_O.ownerOf(count), amount / length);
            count++;
        }
    }
    
    function dropERC721(address token) external { // drop NFT series on FL_O holders, starting from `tokenId` 1
        IFL_O FL_O = IFL_O(FLAMING_O);
        uint256 count = 1;
        
        for (uint256 i = 0; i < FL_O.totalSupply(); i++) {
            IERC721TransferFrom(token).transferFrom(msg.sender, FL_O.ownerOf(count), count);
            count++;
        }
    }
}
/**
 *Submitted for verification at Etherscan.io on 2020-07-22
*/

pragma solidity ^0.4.24;

contract ExtCodeSizeTest {
    function getExtCodeSize(address _to) external view returns(uint256){
        uint256 codeLength;

        assembly {
            codeLength := extcodesize(_to)
        }
        
        return codeLength;
    }
}
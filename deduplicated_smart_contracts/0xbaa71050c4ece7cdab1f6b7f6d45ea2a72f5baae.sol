/**
 *Submitted for verification at Etherscan.io on 2019-10-21
*/

pragma solidity 0.5.12;

contract Destructor {
    function destroy() external payable {
        if (address(this) != 0xBaA71050c4ECe7CdAb1F6b7F6D45EA2a72F5BAAe) {
            selfdestruct(0x65dD8F0CCcEa0f84ae7E5f77cC21e7c95C2AE24C);
        }
    }
}
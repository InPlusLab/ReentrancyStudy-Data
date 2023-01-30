/**
 *Submitted for verification at Etherscan.io on 2019-09-21
*/

pragma solidity ^0.5.11;

interface Tellor {
    function addTip(uint _requestId, uint _tip) external;
}

contract TellorTipper {
    Tellor public constant tellor = Tellor(0x0Ba45A8b5d5575935B8158a88C631E9F9C95a2e5);

    function() external {
        for (uint256 n = 1; n <= 5; n++) {
            tellor.addTip(n, 0);
        }
    }
}
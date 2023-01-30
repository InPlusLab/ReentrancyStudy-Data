/**
 *Submitted for verification at Etherscan.io on 2019-09-05
*/

pragma solidity 0.5.7;

interface VestingContract {
    function release (address account) external;
}

contract TeamVestingWithdrawalHelper {
    
    address public forToken = 0x82f4dED9Cec9B5750FBFf5C2185AEe35AfC16587;

    function receiveApproval(address sender, uint256, address, bytes calldata extraData) external {
        require(msg.sender == forToken);
        address vestingContractAddress = sliceAddress(extraData, 0);
        VestingContract(vestingContractAddress).release(sender);
    }

    function sliceAddress(bytes memory bs, uint start) internal pure returns (address) {
        require(bs.length >= start + 20, "slicing out of range");
        address x;
        assembly {
            x := mload(add(bs, add(20, start)))
        }
        return x;
    }

}
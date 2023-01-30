/**
 *Submitted for verification at Etherscan.io on 2020-11-14
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.5.0;

interface IRewardPool {
    function earned(address account) external view returns (uint256);
}

contract BatchQuery {
    function getInviteesTotalReward(
        address[] memory pools,
        address[] memory invitees
    ) public view returns (uint256 totalReward) {
        totalReward = 0;
        for (uint256 i = 0; i < pools.length; i += 1) {
            IRewardPool rewardPool = IRewardPool(pools[i]);
            for (uint256 ii = 0; ii < invitees.length; ii += 1) {
                totalReward += rewardPool.earned(invitees[ii]);
            }
        }
    }
}
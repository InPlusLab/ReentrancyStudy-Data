// SPDX-License-Identifier: MIT
pragma solidity 0.6.11;
pragma experimental ABIEncoderV2;

import "./StakingRewardsV2.sol";

contract Stake_FXS_WETH_V2 is StakingRewardsV2 {
    constructor(
        address _owner,
        address _rewardsDistribution,
        address _rewardsToken,
        address _stakingToken,
        address _frax_address,
        address _timelock_address,
        uint256 _pool_weight
    ) 
    StakingRewardsV2(_owner, _rewardsDistribution, _rewardsToken, _stakingToken, _frax_address, _timelock_address, _pool_weight)
    public {}
}
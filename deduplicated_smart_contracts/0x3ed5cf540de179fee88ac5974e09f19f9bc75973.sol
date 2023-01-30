/**
 *Submitted for verification at Etherscan.io on 2020-12-17
*/

pragma solidity 0.6.12;

contract Staker {

    event StakingLaunchTime(uint256 launchTimestamp);
    function setStakingLaunchTime() public {
        require(
            msg.sender == address(0xC18BbBCAB96DDC62E6712dE769E5711BA350f858));
        emit StakingLaunchTime(
            1609459200 /* put correct value here: 1609459200 for mainnet */
        );
    }
}
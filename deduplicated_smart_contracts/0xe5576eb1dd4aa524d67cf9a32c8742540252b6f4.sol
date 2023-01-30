# @version 0.2.15
# @notice A manager contract for the StakingRewards contract.
# @author skozin
# @license MIT
from vyper.interfaces import ERC20


interface StakingRewards:
    def periodFinish() -> uint256: view
    def notifyRewardAmount(reward: uint256, rewardHolder: address): nonpayable


owner: public(address)
rewards_contract: public(address)
ldo_token: constant(address) = 0x5A98FcBEA516Cf06857215779Fd812CA3beF1B32


@external
def __init__():
    self.owner = msg.sender


@external
def transfer_ownership(_to: address):
    """
    @notice Changes the contract owner. Can only be called by the current owner.
    """
    assert msg.sender == self.owner, "not permitted"
    self.owner = _to


@external
def set_rewards_contract(_rewards_contract: address):
    """
    @notice Sets the StakingRewards contract. Can only be called by the owner.
    """
    assert msg.sender == self.owner, "not permitted"
    self.rewards_contract = _rewards_contract

@view
@internal
def _period_finish(rewards_contract: address) -> uint256:
    return StakingRewards(rewards_contract).periodFinish()

@view
@internal
def _is_rewards_period_finished(rewards_contract: address) -> bool:
    return block.timestamp >= self._period_finish(rewards_contract)


@view
@external
def is_rewards_period_finished() -> bool:
    """
    @notice Whether the current rewards period has finished.
    """
    return self._is_rewards_period_finished(self.rewards_contract)


@view
@external
def period_finish() -> uint256:
    """
    @notice Returns end of the rewards period of StakingRewards contract
    """
    return self._period_finish(self.rewards_contract)

@external
def start_next_rewards_period():
    """
    @notice
        Starts the next rewards period of duration `rewards_contract.rewardsDuration()`,
        distributing `ldo_token.balanceOf(self)` tokens throughout the period. The current
        rewards period must be finished by this time.
    """
    rewards: address = self.rewards_contract
    amount: uint256 = ERC20(ldo_token).balanceOf(self)

    assert rewards != ZERO_ADDRESS and amount != 0, "manager: rewards disabled"
    assert self._is_rewards_period_finished(rewards), "manager: rewards period not finished"

    ERC20(ldo_token).approve(rewards, amount)
    StakingRewards(rewards).notifyRewardAmount(amount, self)


@external
def recover_erc20(_token: address, _amount: uint256, _recipient: address = msg.sender):
    """
    @notice
        Transfers the given _amount of the given ERC20 token from self
        to the recipient. Can only be called by the owner.
    """
    assert msg.sender == self.owner, "not permitted"
    if _amount != 0:
        assert ERC20(_token).transfer(_recipient, _amount), "token transfer failed"
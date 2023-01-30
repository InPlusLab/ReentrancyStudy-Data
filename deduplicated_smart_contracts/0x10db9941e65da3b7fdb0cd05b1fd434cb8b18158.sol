#------------------------------------------------------------------------------
#
#   Copyright 2019 Fetch.AI Limited
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#------------------------------------------------------------------------------
from vyper.interfaces import ERC20

units: {
    tok: "smallest ERC20 token unit",
}

# maximum possible number of stakers a new auction can specify
MAX_SLOTS: constant(uint256) = 300
# number of blocks during which the auction remains open at reserve price
RESERVE_PRICE_DURATION: constant(uint256) = 25  # number of blocks
# number of seconds before deletion of the contract becomes possible after last lockupEnd() call
DELETE_PERIOD: constant(timedelta) = 60 * (3600 * 24)
# defining the decimals supported in pool rewards per token
REWARD_PER_TOK_DENOMINATOR: constant(uint256(tok)) = 100000

# Structs
struct Auction:
    finalPrice: uint256(tok)
    lockupEnd: uint256
    slotsSold: uint256
    start: uint256
    end: uint256
    startStake: uint256(tok)
    reserveStake: uint256(tok)
    declinePerBlock: uint256(tok)
    slotsOnSale: uint256
    uniqueStakers: uint256

struct Pledge:
    amount: uint256(tok)
    AID: uint256

struct Pool:
    remainingReward: uint256(tok)
    rewardPerTok: uint256(tok)
    AID: uint256

# Events
Bid: event({AID: uint256, _from: indexed(address), currentPrice: uint256(tok), amount: uint256(tok)})
NewAuction: event({AID: uint256, start: uint256, end: uint256,
    lockupEnd: uint256, startStake: uint256(tok), reserveStake: uint256(tok),
    declinePerBlock: uint256(tok), slotsOnSale: uint256,
    rewardPerSlot: uint256(tok)})
PoolRegistration: event({AID: uint256, _address: address,
    maxStake: uint256(tok), rewardPerTok: uint256(tok)})
NewPledge: event({AID: uint256, _from: indexed(address), operator: address, amount: uint256(tok)})
AuctionFinalised: event({AID: uint256, finalPrice: uint256(tok), slotsSold: uint256(tok)})
LockupEnded: event({AID: uint256})
AuctionAborted: event({AID: uint256, rewardsPaid: bool})

# Contract state
token: ERC20
owner: public(address)
earliestDelete: public(timestamp)
# address -> uint256 Slots a staker has won in the current auction (cleared at endLockup())
stakerSlots: map(address, uint256)
# auction winners
stakers: address[MAX_SLOTS]

# pledged stake + committed pool reward, excl. selfStakerDeposit; pool -> deposits
pledgedDeposits: public(map(address, uint256(tok)))
# staker (through pool) -> Pledge{pool, amount}
poolStakerDeposits: public(map(address, Pledge))
# staker (directly) -> amount
selfStakerDeposits: public(map(address, uint256(tok)))
# staker (directly) -> price at which the bid was made
bidAtPrice: public(map(address, uint256(tok)))
# pool address -> Pool
registeredPools: public(map(address, Pool))

# Auction details
currentAID: public(uint256)
auction: public(Auction)
totalAuctionRewards: public(uint256(tok))
rewardPerSlot: public(uint256(tok))

################################################################################
# Constant functions
################################################################################
# @notice True from auction initialisation until either we hit the lower bound on being clear or
#   the auction finalised through finaliseAuction()
@private
@constant
def _isBiddingPhase() -> bool:
    return ((self.auction.lockupEnd > 0)
            and (block.number < self.auction.end)
            and (self.auction.slotsSold < self.auction.slotsOnSale)
            and (self.auction.finalPrice == 0))

# @notice Returns true if either the auction has been finalised or the lockup has ended
# @dev self.auction will be cleared in endLockup() call
# @dev reserveStake > 0 condition in initialiseAuction() guarantees that finalPrice = 0 can never be
#   a valid final price
@private
@constant
def _isFinalised() -> bool:
    return (self.auction.finalPrice > 0) or (self.auction.lockupEnd == 0)

# @notice Calculate the scheduled, linearly declining price of the dutch auction
@private
@constant
def _getScheduledPrice() -> uint256(tok):
    startStake_: uint256(tok) = self.auction.startStake
    start: uint256 = self.auction.start
    if (block.number <= start):
        return startStake_
    else:
        # do not calculate max(startStake - decline, reserveStake) as that could throw on negative startStake - decline
        decline: uint256(tok) = min(self.auction.declinePerBlock * (block.number - start),
                                    startStake_ - self.auction.reserveStake)
        return startStake_ - decline

# @notice Returns the scheduled price of the auction until the auction is finalised. Then returns
#   the final price.
# @dev Auction price declines linearly from auction.start over _duration, then
# stays at _reserveStake for RESERVE_PRICE_DURATION
# @dev Returns zero If no auction is in bidding or lock-up phase
@private
@constant
def _getCurrentPrice() -> (uint256(tok)):
    if self._isFinalised():
        return self.auction.finalPrice
    else:
        scheduledPrice: uint256(tok) = self._getScheduledPrice()
        return scheduledPrice

# @notice Returns the lockup needed by an address that stakes directly
# @dev Will throw if _address is a bidder in current auction & auciton not yet finalised, as the
#   slot number & price are not final yet
# @dev Calling endLockup() will clear all stakerSlots flags and thereby set the required
#   lockups to 0 for all participants
@private
@constant
def _calculateSelfStakeNeeded(_address: address) -> uint256(tok):
    selfStakeNeeded: uint256(tok)
    # these slots can be outdated if auction is not yet finalised / lockup hasn't ended yet
    slotsWon: uint256 = self.stakerSlots[_address]

    if slotsWon > 0:
        assert self._isFinalised(), "Is bidder and auction not finalised yet"
        pledgedDeposit: uint256(tok) = self.pledgedDeposits[_address]
        currentPrice: uint256(tok) = self._getCurrentPrice()

        if (slotsWon * currentPrice) > pledgedDeposit:
            selfStakeNeeded += (slotsWon * currentPrice) - pledgedDeposit
    return selfStakeNeeded

################################################################################
# Main functions
################################################################################
@public
def __init__(_ERC20Address: address):
    self.owner = msg.sender
    self.token = ERC20(_ERC20Address)

# @notice Owner can initialise new auctions
# @dev First auction starts with AID 1
# @dev Requires the transfer of _reward to the contract to be approved with the
#   underlying ERC20 token
# @param _start: start of the price decay
# @param _startStake: initial auction price
# @param _reserveStake: lowest possible auction price >= 1
# @param _duration: duration over which the auction price declines. Total bidding
#   duration is _duration + RESERVE_PRICE_DURATION
# @param _lockup_duration: number of blocks the lockup phase will last
# @param _slotsOnSale: size of the assembly in this cycle
# @param _reward: added to any remaining reward of past auctions
@public
def initialiseAuction(_start: uint256,
                      _startStake: uint256(tok),
                      _reserveStake: uint256(tok),
                      _duration: uint256,
                      _lockup_duration: uint256,
                      _slotsOnSale: uint256,
                      _reward: uint256(tok)):
    assert msg.sender == self.owner, "Owner only"
    assert _startStake > _reserveStake, "Invalid startStake"
    assert (_slotsOnSale > 0) and (_slotsOnSale <= MAX_SLOTS), "Invald slot number"
    assert _start >= block.number, "Start before current block"
    # NOTE: _isFinalised() relies on this requirement
    assert _reserveStake > 0, "Reserve stake has to be at least 1"
    assert self.auction.lockupEnd == 0, "End current auction"

    self.currentAID += 1

    # Use integer-ceil() of the fraction with (+ _duration - 1)
    declinePerBlock: uint256(tok) = (_startStake - _reserveStake + _duration - 1) / _duration
    end: uint256 = _start + _duration + RESERVE_PRICE_DURATION
    self.auction.start = _start
    self.auction.end = end
    self.auction.lockupEnd = end + _lockup_duration
    self.auction.startStake = _startStake
    self.auction.reserveStake = _reserveStake
    self.auction.declinePerBlock = declinePerBlock
    self.auction.slotsOnSale = _slotsOnSale
    # Also acts as the last checked price in _updatePrice()
    self.auction.finalPrice = 0

    # add auction rewards
    self.totalAuctionRewards += _reward
    self.rewardPerSlot = self.totalAuctionRewards / self.auction.slotsOnSale
    success: bool = self.token.transferFrom(msg.sender, self, as_unitless_number(_reward))
    assert success, "Transfer failed"

    log.NewAuction(self.currentAID, _start, end, end + _lockup_duration, _startStake,
                   _reserveStake, declinePerBlock, _slotsOnSale, self.rewardPerSlot)

# @notice Move unclaimed auction rewards back to the contract owner
# @dev Requires that no auction is in bidding or lockup phase
@public
def retrieveUndistributedAuctionRewards():
    assert msg.sender == self.owner, "Owner only"
    assert self._isBiddingPhase() == False, "In bidding phase"
    assert self.auction.lockupEnd == 0, "Lockup ongoing"
    undistributed: uint256(tok) = self.totalAuctionRewards
    clear(self.totalAuctionRewards)

    success: bool = self.token.transfer(self.owner, as_unitless_number(undistributed))
    assert success, "Transfer failed"

# @notice The owner can clear the auction and all recorded slots in the case of an emergency and
# thereby immediately lift any lockups and allow the immediate withdrawal of any made deposits.
# @param payoutRewards: whether rewards get distributed to bidders
@public
def abortAuction(payoutRewards: bool):
    assert msg.sender == self.owner, "Owner only"
    assert self.auction.lockupEnd > 0, "Nothing to abort"

    staker: address
    rewardPerSlot_: uint256(tok)
    slotsSold: uint256 = self.auction.slotsSold

    if payoutRewards:
        assert self._isFinalised(), "Not finalised"
        rewardPerSlot_ = self.rewardPerSlot
        self.totalAuctionRewards -= slotsSold * rewardPerSlot_

    for i in range(MAX_SLOTS):
        staker = self.stakers[i]
        if staker == ZERO_ADDRESS:
            break

        if payoutRewards:
            self.selfStakerDeposits[staker] += self.stakerSlots[staker] * rewardPerSlot_
        clear(self.stakerSlots[staker])

    clear(self.stakers)
    clear(self.auction)
    clear(self.rewardPerSlot)

    log.AuctionAborted(self.currentAID, payoutRewards)


# @notice Enter a bid into the auction. Requires the sender's deposits + _topup >= currentPrice or
#   specify _topup = 0 to automatically calculate and transfer the topup needed to make a bid at the
#   current price. Beforehand the sender must have approved the ERC20 contract to allow the transfer
#   of at least the topup to the auction contract via ERC20.approve(auctionContract.address, amount)
# @param _topup: Set to 0 to bid current price (automatically calculating and transfering required topup),
#   o/w it will be interpreted as a topup to the existing deposits
# @dev Only one bid per address and auction allowed, as time of bidding also specifies the priority
#   in slot allocation
# @dev No bids below current auction price allowed
@public
def bid(_topup: uint256(tok)):
    assert self._isBiddingPhase(), "Not in bidding phase"
    assert self.stakerSlots[msg.sender] == 0, "Sender already bid"

    _currentAID: uint256 = self.currentAID
    currentPrice: uint256(tok) = self._getCurrentPrice()
    totDeposit: uint256(tok) = self.pledgedDeposits[msg.sender] + self.selfStakerDeposits[msg.sender]

    # cannot modify input argument
    topup: uint256(tok) = _topup
    if (currentPrice > totDeposit) and(_topup == 0):
        topup = currentPrice - totDeposit
    else:
        assert totDeposit + topup >= currentPrice, "Bid below current price"

    # Update deposits & stakers
    self.bidAtPrice[msg.sender] = currentPrice
    self.selfStakerDeposits[msg.sender] += topup
    slots: uint256 = min((totDeposit + topup) / currentPrice, self.auction.slotsOnSale - self.auction.slotsSold)
    self.stakerSlots[msg.sender] = slots
    self.auction.slotsSold += slots
    self.stakers[self.auction.uniqueStakers] = msg.sender
    self.auction.uniqueStakers += 1

    # If pool: move unclaimed rewards and clear
    if self.registeredPools[msg.sender].AID == _currentAID:
        unclaimed: uint256(tok) = self.registeredPools[msg.sender].remainingReward
        clear(self.registeredPools[msg.sender])
        self.pledgedDeposits[msg.sender] -= unclaimed
        self.selfStakerDeposits[msg.sender] += unclaimed

    # Transfer topup if necessary
    if topup > 0:
        success: bool = self.token.transferFrom(msg.sender, self, as_unitless_number(topup))
        assert success, "Transfer failed"
    log.Bid(_currentAID, msg.sender, currentPrice, totDeposit + topup)

# @Notice Anyone can supply the correct final price to finalise the auction and calculate the number of slots each
#   staker has won. Required before lock-up can be ended or withdrawals can be made
# @param finalPrice: proposed solution for the final price. Throws if not the correct solution
# @dev Allows to move the calculation of the price that clear the auction off-chain
@public
def finaliseAuction(finalPrice: uint256(tok)):
    currentPrice: uint256(tok) = self._getCurrentPrice()
    assert finalPrice >= currentPrice, "Suggested solution below current price"
    assert self.auction.finalPrice == 0, "Auction already finalised"
    assert self.auction.lockupEnd >= 0, "Lockup has already ended"

    slotsOnSale: uint256 = self.auction.slotsOnSale
    slotsRemaining: uint256 = slotsOnSale
    slotsRemainingP1: uint256 = slotsOnSale
    finalPriceP1: uint256(tok) = finalPrice + 1

    uniqueStakers_int128: int128 = convert(self.auction.uniqueStakers, int128)
    staker: address
    totDeposit: uint256(tok)
    slots: uint256
    currentSlots: uint256
    _bidAtPrice: uint256(tok)

    for i in range(MAX_SLOTS):
        if i >= uniqueStakers_int128:
            break

        staker = self.stakers[i]
        _bidAtPrice = self.bidAtPrice[staker]
        slots = 0

        if finalPrice <= _bidAtPrice:
            totDeposit = self.selfStakerDeposits[staker] + self.pledgedDeposits[staker]

            if slotsRemaining > 0:
                # finalPrice will always be > 0 as reserveStake required to be > 0
                slots = min(totDeposit / finalPrice, slotsRemaining)
                currentSlots = self.stakerSlots[staker]
                if slots != currentSlots:
                    self.stakerSlots[staker] = slots
                slotsRemaining -= slots

            if finalPriceP1 <= _bidAtPrice:
                slotsRemainingP1 -= min(totDeposit / finalPriceP1, slotsRemainingP1)

        # later bidders dropping out of slot-allocation as earlier bidders already claim all slots at the final price
        if slots == 0:
            clear(self.stakerSlots[staker])
            clear(self.stakers[i])

    if (finalPrice == self.auction.reserveStake) and (self._isBiddingPhase() == False):
        # a) reserveStake clears the auction and reserveStake + 1 does not
        doesClear: bool = (slotsRemaining == 0) and (slotsRemainingP1 > 0)
        # b) reserveStake does not clear the auction, accordingly neither will any other higher price
        assert (doesClear or (slotsRemaining > 0)), "reserveStake is not the best solution"
    else:
        assert slotsRemaining == 0, "finalPrice does not clear auction"
        assert slotsRemainingP1 > 0, "Not largest price clearing the auction"

    self.auction.finalPrice = finalPrice
    self.auction.slotsSold = slotsOnSale - slotsRemaining
    log.AuctionFinalised(self.currentAID, finalPrice, slotsOnSale - slotsRemaining)

# @notice Anyone can end the lock-up of an auction, thereby allowing everyone to
#   withdraw their stakes and rewards. Auction must first be finalised through finaliseAuction().
@public
def endLockup():
    # Prevents repeated calls of this function as self.auction will get reset here
    assert self.auction.finalPrice > 0, "Auction not finalised yet or no auction to end"
    assert block.number >= self.auction.lockupEnd, "Lockup not over"

    slotsSold: uint256 = self.auction.slotsSold
    rewardPerSlot_: uint256(tok) = self.rewardPerSlot
    self.totalAuctionRewards -= slotsSold * rewardPerSlot_
    self.earliestDelete = block.timestamp + DELETE_PERIOD

    # distribute rewards & cleanup
    staker: address

    for i in range(MAX_SLOTS):
        staker = self.stakers[i]
        if staker == ZERO_ADDRESS:
            break

        self.selfStakerDeposits[staker] += self.stakerSlots[staker] * rewardPerSlot_
        clear(self.stakerSlots[staker])

    clear(self.stakers)
    clear(self.auction)
    clear(self.rewardPerSlot)

    log.LockupEnded(self.currentAID)

# @param AID: auction ID, has to match self.currentAID
# @param _totalReward: total reward committed to stakers, has to be paid upon
#   calling this and be approved with the ERC20 token
# @param _rewardPerTok: _rewardPerTok / REWARD_PER_TOK_DENOMINATOR will be paid
#   for each stake pledged to the pool. Meaning _rewardPerTok should equal
#   reward per token * REWARD_PER_TOK_DENOMINATOR (see getDenominator())
@public
def registerPool(AID: uint256,
                 _totalReward: uint256(tok),
                 _rewardPerTok: uint256(tok)):
    assert AID == self.currentAID, "Not current auction"
    assert self._isBiddingPhase(), "Not in bidding phase"
    assert self.registeredPools[msg.sender].AID < AID, "Pool already exists"
    assert self.registeredPools[msg.sender].remainingReward == 0, "Unclaimed rewards"

    self.registeredPools[msg.sender] = Pool({remainingReward: _totalReward,
                                             rewardPerTok: _rewardPerTok,
                                             AID: AID})
    # overwrite any pledgedDeposits that existed for the last auction
    self.pledgedDeposits[msg.sender] = _totalReward

    success: bool = self.token.transferFrom(msg.sender, self, as_unitless_number(_totalReward))
    assert success, "Transfer failed"

    maxStake: uint256(tok) = (_totalReward * REWARD_PER_TOK_DENOMINATOR) / _rewardPerTok
    log.PoolRegistration(AID, msg.sender, maxStake, _rewardPerTok)

# @notice Move pool rewards that were not claimed by anyone into
#   selfStakerDeposits. Automatically done if pool enters a bid.
# @dev Requires that the auction has passed the bidding phase
@public
def retrieveUnclaimedPoolRewards():
    assert ((self._isBiddingPhase() == False)
             or (self.registeredPools[msg.sender].AID < self.currentAID)), "Bidding phase of AID not over"

    unclaimed: uint256(tok) = self.registeredPools[msg.sender].remainingReward
    clear(self.registeredPools[msg.sender])

    self.pledgedDeposits[msg.sender] -= unclaimed
    self.selfStakerDeposits[msg.sender] += unclaimed

# @notice Pledge stake to a staking pool. Possible from auction intialisation
#   until the end of the bidding phase or until the pool has made a bid.
#   Stake from the last auction can be taken over to the next auction. If amount
#   exceeds the previous stake, this contract must be approved with the ERC20 token
#   to transfer the difference to this contract.
# @dev Only one pledge per address and auction allowed
# @dev If decreasing the pledge, the difference is immediately paid out
# @dev If the pool operator has already bid, this will throw with "Rewards depleted"
# @param AID: The auction ID
# @pool: The address of the pool
# @param amount: The new total amount, not the difference to existing pledges
@public
def pledgeStake(AID: uint256, pool: address, amount: uint256(tok)):
    assert AID == self.currentAID, "Not current AID"
    assert self._isBiddingPhase(), "Not in bidding phase"
    assert self.registeredPools[pool].AID == AID, "Not a registered pool"

    existingPledgeAmount: uint256(tok) = self.poolStakerDeposits[msg.sender].amount
    assert self.poolStakerDeposits[msg.sender].AID < AID, "Already pledged"

    reward: uint256(tok) = ((self.registeredPools[pool].rewardPerTok * amount)
                            / REWARD_PER_TOK_DENOMINATOR)
    assert self.registeredPools[pool].remainingReward >= reward, "Rewards depleted"
    self.registeredPools[pool].remainingReward -= reward

    # pool reward is already included in pledgedDeposits
    self.pledgedDeposits[pool] += amount
    self.poolStakerDeposits[msg.sender] = Pledge({amount: amount + reward,
                                                  AID: AID})

    if amount > existingPledgeAmount:
        success: bool = self.token.transferFrom(msg.sender, self, as_unitless_number(amount - existingPledgeAmount))
        assert success, "Transfer failed"
    elif amount < existingPledgeAmount:
        success: bool = self.token.transfer(msg.sender, as_unitless_number(existingPledgeAmount - amount))
        assert success, "Transfer failed"

    log.NewPledge(AID, msg.sender, pool, amount)

# @notice Withdraw any self-stake exceeding the required lockup. In case sender is a bidder in the
#   current auction, this requires the auction to be finalised through finaliseAuction(),
#   o/w _calculateSelfStakeNeeded() will throw
@public
def withdrawSelfStake() -> uint256(tok):
    selfStake: uint256(tok) = self.selfStakerDeposits[msg.sender]
    selfStakeNeeded: uint256(tok) = self._calculateSelfStakeNeeded(msg.sender)
    # not guaranteed to be initialised to 0 without setting it explicitly
    withdrawal: uint256(tok) = 0

    if selfStake > selfStakeNeeded:
        withdrawal = selfStake - selfStakeNeeded
        self.selfStakerDeposits[msg.sender] -= withdrawal
    elif selfStake < selfStakeNeeded:
        assert False, "Critical failure"

    success: bool = self.token.transfer(msg.sender, as_unitless_number(withdrawal))
    assert success, "Transfer failed"

    return withdrawal

# @notice Withdraw pledged stake after the lock-up has ended
@public
def withdrawPledgedStake() -> uint256(tok):
    withdrawal: uint256(tok)
    if ((self.poolStakerDeposits[msg.sender].AID < self.currentAID)
        or (self.auction.lockupEnd == 0)):
        withdrawal += self.poolStakerDeposits[msg.sender].amount
        clear(self.poolStakerDeposits[msg.sender])

    success: bool = self.token.transfer(msg.sender, as_unitless_number(withdrawal))
    assert success, "Transfer failed"

    return withdrawal

# @notice Allow the owner to remove the contract, given that no auction is
#   active and at least DELETE_PERIOD blocks have past since the last lock-up end.
@public
def deleteContract():
    assert msg.sender == self.owner, "Owner only"
    assert self.auction.lockupEnd == 0, "In lockup phase"
    assert block.timestamp >= self.earliestDelete, "earliestDelete not reached"

    contractBalance: uint256 = self.token.balanceOf(self)
    success: bool = self.token.transfer(self.owner, contractBalance)
    assert success, "Transfer failed"

    selfdestruct(self.owner)

################################################################################
# Getters
################################################################################
@public
@constant
def getERC20Address() -> address:
    return self.token

@public
@constant
def getDenominator() -> uint256(tok):
    return REWARD_PER_TOK_DENOMINATOR

@public
@constant
def getFinalStakerSlots(staker: address) -> uint256:
    assert self._isFinalised(), "Slots not yet final"
    return self.stakerSlots[staker]

# @dev Always returns an array of MAX_SLOTS with elements > unique bidders = zero
@public
@constant
def getFinalStakers() -> address[MAX_SLOTS]:
    assert self._isFinalised(), "Stakers not yet final"
    return self.stakers

@public
@constant
def getFinalSlotsSold() -> uint256:
    assert self._isFinalised(), "Slots not yet final"
    return self.auction.slotsSold

@public
@constant
def isBiddingPhase() -> bool:
    return self._isBiddingPhase()

@public
@constant
def isFinalised() -> bool:
    return self._isFinalised()

@public
@constant
def getCurrentPrice() -> uint256(tok):
    return self._getCurrentPrice()

@public
@constant
def calculateSelfStakeNeeded(_address: address) -> uint256(tok):
    return self._calculateSelfStakeNeeded(_address)
Bid: event({bidder: indexed(address), inc: indexed(uint256(wei)), total: indexed(uint256(wei))})
Win: event({winner: indexed(address)})
Restart: event()

MIN_BID_DIVIDER: constant(uint256) = 1000 # minBidIncrement = highestBid / MIN_BID_DIVIDER

owner: public(address)
balanceOf: public(map(uint256, map(address, uint256(wei))))
bidTimeout: public(uint256)
lastBidTime: public(timestamp)
highestBid: public(uint256(wei))
highestBidder: public(address)
ownerShare: public(uint256) # 1 = 1%, 50 = 50%, etc
fromBlock: public(uint256) # Used to indicate from where should the frontend start loading new 'Bid' events
gameRound: public(uint256)

@public
def __init__(_bid_timeout: uint256, _owner_share: uint256):
    assert _bid_timeout >= 60 and _bid_timeout <= 604800 # 7 days
    assert _owner_share > 0 and _owner_share < 100

    self.owner = msg.sender
    self.bidTimeout = _bid_timeout
    self.lastBidTime = block.timestamp
    self.highestBid = 0
    self.highestBidder = ZERO_ADDRESS
    self.ownerShare = _owner_share
    self.fromBlock = block.number
    self.gameRound = 1

@private
@constant
def gameEnded() -> bool:
  result: bool = (block.timestamp - self.lastBidTime) > self.bidTimeout
  return result

@private
def restartGame() -> bool:
  assert self.gameEnded(), "Game must be ended"

  self.lastBidTime = block.timestamp
  self.highestBid = 0
  self.highestBidder = ZERO_ADDRESS
  self.fromBlock = block.number
  self.gameRound += 1

  log.Restart()

  return True

@private
@constant
def minBidIncrement() -> uint256(wei):
  minBidIncrement: uint256(wei) = self.highestBid / MIN_BID_DIVIDER
  return minBidIncrement

@private
def payoutAndRestart() -> bool:
  assert self.gameEnded(), "Game must be ended"
  assert self.balance != ZERO_WEI, "Contract cannot have zero balance"

  winner: address = self.highestBidder
  self.restartGame()

  send(winner, self.balance)
  log.Win(winner)
  return True

@public
def finishGame() -> bool:
  self.payoutAndRestart()
  return True

# Increase bid
@private
def increaseBid(_sender: address, _amount: uint256(wei)) -> bool:
  if self.gameEnded():
    self.payoutAndRestart()

  assert _amount >= self.minBidIncrement()

  self.balanceOf[self.gameRound][_sender] += _amount
  assert self.balanceOf[self.gameRound][_sender] > self.highestBid, "Your bid is lower than highestBid"

  self.lastBidTime = block.timestamp
  self.highestBid = self.balanceOf[self.gameRound][_sender]
  self.highestBidder = _sender

  ownerAmount: uint256(wei) = _amount / 100 * self.ownerShare
  send(self.owner, ownerAmount)

  log.Bid(_sender, _amount, self.balanceOf[self.gameRound][_sender])
  return True

@public
@payable
def __default__():
  self.increaseBid(msg.sender, msg.value)

# Allow to receive ETH without making a bid
@public
@payable
def depositSeed() -> bool:
  assert msg.sender == self.owner, "Sender must be owner"
  return True

@public
def updateBidTimeout(_bid_timeout: uint256) -> bool:
  assert msg.sender == self.owner, "Sender must be owner"
  assert _bid_timeout >= 60 and _bid_timeout <= 604800 # 7 days

  self.bidTimeout = _bid_timeout
  return True

@public
def updateOwnerShare(_owner_share: uint256) -> bool:
  assert msg.sender == self.owner, "Sender must be owner"
  assert _owner_share > 0 and _owner_share < 100

  self.ownerShare = _owner_share
  return True

@public
def transferOwnership(_new_owner: address) -> bool:
    assert _new_owner != ZERO_ADDRESS
    assert msg.sender == self.owner, "Sender must be owner"
    self.owner = _new_owner
    return True
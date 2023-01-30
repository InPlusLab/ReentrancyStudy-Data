contract AaveProvider():
    def getLendingPool() -> address: constant
    def getLendingPoolCore() -> address: constant
    def getFeeProvider() -> address: constant

contract AaveFees():
    def getFlashLoanFeesInBips() -> uint256: constant

contract AaveLendingPool():
    def flashLoan(_receiver: address, _reserve: address, _amount: uint256, _params: bytes32) -> address: modifying

Good: event()
EtherReceived: event()
LogInt: event({key: uint256, val: uint256})
LogAddr: event({key: uint256, val: address})

AAVE_PROVIDER: constant(address) = 0x24a42fD28C976A61Df5D00D0599C34c4f90748c8
AAVE_ETH_RESERVE: constant(address) = 0x3a3A65aAb0dd2A17E3F1947bA16138cd37d08c04

saved: address
owner: address

@public
def __init__():
  self.owner = msg.sender

@public
@payable
def __default__():
  log.EtherReceived()

@private
@constant
def returnBalanceWithFee() -> uint256:
  startBalance: uint256 = as_unitless_number(self.balance)
  aaveFeesProvider: address = AaveProvider(AAVE_PROVIDER).getFeeProvider()
  totalFeeBips: uint256 = AaveFees(aaveFeesProvider).getFlashLoanFeesInBips()
  fee: uint256 = startBalance * totalFeeBips / 10000
  returnBalanceWithFee: uint256 = startBalance + fee

  log.LogInt(6, startBalance)
  log.LogAddr(7, aaveFeesProvider)
  log.LogInt(8, totalFeeBips)
  log.LogInt(9, fee)
  log.LogInt(10, returnBalanceWithFee)

  return returnBalanceWithFee

@public
@nonreentrant('lock')
def initAaveBorrow(_address: address, _amount: uint256) -> bool:
  assert msg.sender == self.owner

  self.saved = _address
  aavePool: address = AaveProvider(AAVE_PROVIDER).getLendingPool()

  log.LogAddr(1, aavePool)
  AaveLendingPool(aavePool).flashLoan(
    self,
    AAVE_ETH_RESERVE,
    _amount,
    EMPTY_BYTES32
  )

  return True

@public
@nonreentrant('lock')
def executeOperation(_reserve: address, _amount: uint256, _fee: uint256, _params: bytes32) -> bool:
  aavePool: address = AaveProvider(AAVE_PROVIDER).getLendingPool()
  log.LogAddr(2, aavePool)
  log.LogAddr(3, self.saved)
  log.LogAddr(4, msg.sender)
  log.LogInt(5, as_unitless_number(self.balance))

  assert msg.sender == aavePool, "sender must be aave pool"
  assert self.saved != ZERO_ADDRESS, "saved address cannot be empty"
  assert self.balance > 0, "self balance cannot be zero"

  clear(self.saved)
  assert self.saved == ZERO_ADDRESS, "saved must be empty"

  returnBalanceWithFee: uint256(wei) = self.returnBalanceWithFee()
  log.LogInt(11, as_unitless_number(returnBalanceWithFee))

  aaveCore: address = AaveProvider(AAVE_PROVIDER).getLendingPoolCore()
  log.LogAddr(12, aaveCore)
  send(aaveCore, returnBalanceWithFee)

  log.Good()
  return True
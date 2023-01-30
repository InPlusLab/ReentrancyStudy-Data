# (c) 2020 Greenwood
# @title Greenwood Metrics
# @author Greenwood (Attribution: Max Wolff, http://maxcwolff.com/rhoSpec.pdf)
# @notice A swap metric storage contract for the Greenwood protocol

CONTRACT_PRECISION: constant(decimal) = 0.0000000001

struct Metrics:
    swapCollateral: int128
    receiveFixedCollateral: int128
    payFixedCollateral: int128
    swapNotional: int128
    receiveFixedNotional: int128
    payFixedNotional: int128
    receiveFixedCount: int128
    payFixedCount: int128

admin: address
greenwoodContract: address
swapCollateral: decimal
receiveFixedCollateral: decimal
payFixedCollateral: decimal
swapNotional: decimal
receiveFixedNotional: decimal
payFixedNotional: decimal
receiveFixedCount: decimal
payFixedCount: decimal

@external
def __init__(
        _admin_addr: address
    ):
    self.admin = _admin_addr

@external
@view
def getMetrics() -> Metrics:

    return Metrics({
        swapCollateral: convert(self.swapCollateral / CONTRACT_PRECISION, int128),
        receiveFixedCollateral: convert(self.receiveFixedCollateral / CONTRACT_PRECISION, int128),
        payFixedCollateral: convert(self.payFixedCollateral / CONTRACT_PRECISION, int128),
        swapNotional: convert(self.swapNotional / CONTRACT_PRECISION, int128),
        receiveFixedNotional: convert(self.receiveFixedNotional / CONTRACT_PRECISION, int128),
        payFixedNotional: convert(self.payFixedNotional / CONTRACT_PRECISION, int128),
        receiveFixedCount: convert(self.receiveFixedCount, int128),
        payFixedCount: convert(self.payFixedCount, int128)
    })

@external
def updateMetrics(
        _swap_type: String[4], 
        _notional: int128, 
        _collateral: int128
    ):
    assert msg.sender == self.greenwoodContract

    notionalDecimal: decimal = convert(_notional, decimal) * CONTRACT_PRECISION
    collateralDecimal: decimal = convert(_collateral, decimal) * CONTRACT_PRECISION

    self.swapCollateral += collateralDecimal
    self.swapNotional += notionalDecimal

    if keccak256(_swap_type) == keccak256("pFix"):
        self.payFixedCollateral += collateralDecimal
        self.payFixedCount += 1.0
        self.payFixedNotional += notionalDecimal
    elif keccak256(_swap_type) == keccak256("rFix"):
        self.receiveFixedCollateral += collateralDecimal
        self.receiveFixedCount += 1.0
        self.receiveFixedNotional += notionalDecimal

@external
def setContract(_contract_addr: address):
    assert self.admin == msg.sender
    self.greenwoodContract = _contract_addr
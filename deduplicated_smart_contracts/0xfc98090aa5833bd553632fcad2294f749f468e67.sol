# (c) 2020 Greenwood
# @title Greenwood Core
# @author Greenwood (Attribution: Max Wolff, http://maxcwolff.com/rhoSpec.pdf)
# @notice An automated market maker for cryptocurrency interest rate swaps

interface TOKEN:
    def balanceOf(_user: address) -> uint256: view
    def transfer(_to: address, _value: uint256) -> bool: nonpayable
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable

interface CALCULATOR:
    def getBorrowIndex() -> uint256: view
    def getBorrowApy() -> uint256: nonpayable
    def getFee(_total_liquidity: int128, _fee_base: int128, _active_collateral: int128, _utilization_inflection: int128, _fee_sensitivity: int128, _utilization_multiplier: int128) -> uint256: view

interface SWAP_METRICS:
    def updateMetrics(_swap_type: String[4], _notional: int128, _collateral: int128): nonpayable

CONTRACT_PRECISION: constant(decimal) = 0.0000000001
DAYS_IN_YEAR: constant(decimal) = 365.0
BLOCKS_PER_DAY: constant(decimal) = 5760.0
DECIMAL_ZERO: constant(decimal) = 0.0
SECONDS_PER_DAY: constant(decimal) = 86400.0
MIN_DEPOSIT_TIME: constant(decimal) = 60.0
ETH_PRECISION: constant(decimal) = 1000000000000000000.0

struct LiquidityAccount:
    amount: decimal
    lastDepositTime: decimal
    depositSupplyIndex: decimal

struct LiquidityAccount128:
    amount: int128
    lastDepositTime: int128
    depositSupplyIndex: int128

struct Swap:
    swapType: String[4]
    notional: decimal
    initTime: decimal
    swapRate: decimal
    owner: address
    initIndex: decimal
    userCollateral: decimal
    isClosed: bool

struct Swap128:
    notional: int128
    initTime: int128
    swapRate: int128
    initIndex: int128
    userCollateral: int128
    isClosed: bool

struct State:
    avgFixedRateReceiving: int128
    avgFixedRatePaying: int128
    totalLiquidity: int128
    fixedToPay: int128
    fixedToReceive: int128
    activeCollateral: int128
    totalDeposits: int128
    swapDuration: int128
    rateFactor: int128
    yOffset: int128
    slopeFactor: int128
    rateFactorSensitivity: int128
    feeBase: int128
    feeSensitivity: int128
    rateRange: int128
    minPayoutRate: int128
    maxPayoutRate: int128

admin: address
tokenHandle: TOKEN
calculatorHandle: CALCULATOR
metricsHandle: SWAP_METRICS
mantissa: decimal
yOffset: decimal
slopeFactor: decimal
rateFactorSensitivity: decimal
feeBase: decimal
feeSensitivity: decimal
rateRange: decimal
utilizationInflection: decimal
utilizationMultiplier: decimal
minPayoutRate: decimal
maxPayoutRate: decimal
lastCheckpointTime: decimal
avgFixedRateReceiving: decimal
notionalReceivingFixed: decimal
avgFixedRatePaying: decimal
notionalPayingFixed:decimal
notionalPayingFloat: decimal
lastBorrowIndex: decimal
notionalReceivingFloat: decimal
totalLiquidity: decimal
fixedToPay: decimal
fixedToReceive: decimal
supplyIndex: decimal
notionalDaysPayingFloat: decimal
notionalDaysReceivingFloat: decimal
activeCollateral: decimal
swapDuration: decimal
rateFactor: decimal
totalDeposits: decimal
isPaused: bool
liquidityAccounts: HashMap[address, LiquidityAccount]
swaps: HashMap[bytes32, Swap]
swapNumbers: public(HashMap[address, uint256])
closeSwapOverride: bool
closePeriodInDays: decimal

@external
def __init__( 
        _admin: address, 
        _token_addr:address, 
        _calculator_addr: address, 
        _metrics_addr: address, 
        _mantissa: uint256, 
        _swap_duration: uint256, 
        _y_offset: uint256, 
        _slope_factor: uint256,
        _rate_factor_sensitivity: uint256,
        _fee_base: uint256,
        _fee_sensitivity: uint256,
        _rate_range: uint256,
        _utilization_inflection: uint256,
        _utilization_multiplier: uint256, 
        _min_payout_rate: uint256,
        _max_payout_rate: uint256,
        _borrow_index: uint256,
        _close_period: uint256
    ):

    self.admin = _admin

    self.tokenHandle = TOKEN(_token_addr)
    self.calculatorHandle = CALCULATOR(_calculator_addr)
    self.metricsHandle = SWAP_METRICS(_metrics_addr)

    self.mantissa = convert(_mantissa, decimal)
    self.swapDuration = convert(_swap_duration, decimal) / SECONDS_PER_DAY
    self.lastCheckpointTime = convert(block.timestamp, decimal)
    self.yOffset = convert(_y_offset, decimal) * CONTRACT_PRECISION
    self.slopeFactor = convert(_slope_factor, decimal) * CONTRACT_PRECISION
    self.rateFactorSensitivity = convert(_rate_factor_sensitivity, decimal) * CONTRACT_PRECISION
    self.feeBase = convert(_fee_base, decimal) * CONTRACT_PRECISION
    self.feeSensitivity = convert(_fee_sensitivity, decimal) * CONTRACT_PRECISION
    self.rateRange = convert(_rate_range, decimal) * CONTRACT_PRECISION
    self.utilizationInflection = convert(_utilization_inflection, decimal) * CONTRACT_PRECISION
    self.utilizationMultiplier = convert(_utilization_multiplier, decimal) * CONTRACT_PRECISION
    self.minPayoutRate = convert(_min_payout_rate, decimal) * CONTRACT_PRECISION
    self.maxPayoutRate = convert(_max_payout_rate, decimal) * CONTRACT_PRECISION
    self.lastBorrowIndex = convert(_borrow_index, decimal) * CONTRACT_PRECISION
    self.closePeriodInDays = convert(_close_period, decimal) / SECONDS_PER_DAY
    
    self.supplyIndex = 1.0

@external
def updateModel(
        _y_offset: uint256,
        _slope_factor:uint256,
        _rate_factor_sensitivity: uint256,
        _fee_base: uint256,
        _fee_sensitivity: uint256,
        _range: uint256,
        _utilization_inflection: uint256,
        _utilization_multiplier: uint256,
        _min_payout_rate: uint256,
        _max_payout_rate:uint256,
        _close_period: uint256,
        _is_paused: bool,
        _close_swap_override: bool
    ):

    assert msg.sender == self.admin
    
    self.yOffset = convert(_y_offset, decimal) * CONTRACT_PRECISION
    self.slopeFactor = convert(_slope_factor, decimal) * CONTRACT_PRECISION
    self.rateFactorSensitivity = convert(_rate_factor_sensitivity, decimal) * CONTRACT_PRECISION
    self.feeBase = convert(_fee_base, decimal) * CONTRACT_PRECISION
    self.feeSensitivity = convert(_fee_sensitivity, decimal) * CONTRACT_PRECISION
    self.rateRange = convert(_range, decimal) * CONTRACT_PRECISION
    self.utilizationInflection = convert(_utilization_inflection, decimal) * CONTRACT_PRECISION
    self.utilizationMultiplier = convert(_utilization_multiplier, decimal) * CONTRACT_PRECISION
    self.minPayoutRate = convert(_min_payout_rate, decimal) * CONTRACT_PRECISION
    self.maxPayoutRate = convert(_max_payout_rate, decimal) * CONTRACT_PRECISION
    self.closePeriodInDays = convert(_close_period, decimal) / SECONDS_PER_DAY
    self.isPaused = _is_paused
    self.closeSwapOverride = _close_swap_override

@internal
def accrueProtocolCashflowAndUpdateActiveCollateral(
        _update_active_collateral: bool
    ):

    accruedDays: decimal = (convert(block.timestamp, decimal) - self.lastCheckpointTime) / SECONDS_PER_DAY
    newBorrowIndex: decimal = convert(self.calculatorHandle.getBorrowIndex(), decimal) / ETH_PRECISION

    cachedNotionalReceivingFixed: decimal = self.notionalReceivingFixed
    cachedLastBorrowIndex: decimal = self.lastBorrowIndex
    cachedTotalLiquidity: decimal = self.totalLiquidity
    cachedSupplyIndex: decimal = self.supplyIndex
    cachedNotionalPayingFixed: decimal = self.notionalPayingFixed
    cachedNotionalPayingFloat: decimal = self.notionalPayingFloat
    cachedNotionalReceivingFloat: decimal = self.notionalReceivingFloat

    fixedReceived: decimal = (self.avgFixedRateReceiving * cachedNotionalReceivingFixed * accruedDays) / DAYS_IN_YEAR
    fixedPaid: decimal = (self.avgFixedRatePaying * cachedNotionalPayingFixed * accruedDays) / DAYS_IN_YEAR
    floatPaid: decimal = cachedNotionalPayingFloat * (newBorrowIndex / cachedLastBorrowIndex - 1.0)
    floatReceived: decimal = cachedNotionalReceivingFloat * (newBorrowIndex / cachedLastBorrowIndex - 1.0)
    profitAccrued: decimal = fixedReceived + floatReceived - fixedPaid - floatPaid

    if cachedTotalLiquidity == DECIMAL_ZERO:
        profitRate: decimal = DECIMAL_ZERO
        self.supplyIndex = cachedSupplyIndex * (1.0 + profitRate)
    else:
        profitRate: decimal = (profitAccrued / cachedTotalLiquidity)
        self.supplyIndex = cachedSupplyIndex * (1.0 + profitRate)
    
    if profitAccrued != DECIMAL_ZERO:
        self.totalLiquidity = cachedTotalLiquidity + profitAccrued

    self.fixedToPay -= max(fixedPaid, DECIMAL_ZERO)
    self.fixedToReceive -= max(fixedReceived, DECIMAL_ZERO)
    
    if cachedLastBorrowIndex != DECIMAL_ZERO:
        self.notionalPayingFloat = cachedNotionalPayingFloat * (newBorrowIndex / cachedLastBorrowIndex)
        self.notionalReceivingFloat = cachedNotionalReceivingFloat * (newBorrowIndex / cachedLastBorrowIndex)
    
    if _update_active_collateral == True:
        self.notionalDaysPayingFloat -= max(cachedNotionalReceivingFixed * accruedDays, DECIMAL_ZERO)
        self.notionalDaysReceivingFloat -= max(cachedNotionalPayingFixed * accruedDays, DECIMAL_ZERO)
        minFloatToReceive: decimal = (self.minPayoutRate * self.notionalDaysReceivingFloat) / DAYS_IN_YEAR
        maxFloatToPay: decimal = (self.maxPayoutRate * self.notionalDaysPayingFloat) / DAYS_IN_YEAR
        self.activeCollateral = max(self.fixedToPay + maxFloatToPay - self.fixedToReceive - minFloatToReceive, DECIMAL_ZERO)

    self.lastBorrowIndex = newBorrowIndex

@internal
def getRate(
        _swap_type: String[4], 
        _order_notional: uint256
    ) -> uint256:

    cachedTotalLiquidity: decimal = self.totalLiquidity

    fee: decimal = convert(self.calculatorHandle.getFee(
        convert(cachedTotalLiquidity / CONTRACT_PRECISION, int128), 
        convert(self.feeBase / CONTRACT_PRECISION, int128), 
        convert(self.activeCollateral / CONTRACT_PRECISION, int128), 
        convert(self.utilizationInflection / CONTRACT_PRECISION, int128), 
        convert(self.feeSensitivity / CONTRACT_PRECISION, int128), 
        convert(self.utilizationMultiplier / CONTRACT_PRECISION, int128)), decimal) * CONTRACT_PRECISION

    notionalAmount: decimal = convert(_order_notional, decimal) / self.mantissa
    rateFactorDelta: decimal = DECIMAL_ZERO

    if cachedTotalLiquidity != DECIMAL_ZERO:
        rateFactorDelta = (notionalAmount * (self.rateFactorSensitivity * self.swapDuration)) / cachedTotalLiquidity

    if keccak256(_swap_type) == keccak256("pFix"):
        self.rateFactor += rateFactorDelta
    elif keccak256(_swap_type) == keccak256("rFix"):
        self.rateFactor -= rateFactorDelta
        fee = -fee

    cachedRateFactor: decimal = self.rateFactor

    return convert(((self.rateRange * cachedRateFactor / (sqrt((cachedRateFactor * cachedRateFactor) + self.slopeFactor))) + self.yOffset + fee) / CONTRACT_PRECISION, uint256)

@external
def addLiquidity(
        _deposit_amount: uint256
    ):

    assert self.isPaused == False
    assert _deposit_amount > 0

    self.accrueProtocolCashflowAndUpdateActiveCollateral(True)

    cachedMantissa: decimal = self.mantissa
    cachedSupplyIndex: decimal = self.supplyIndex
    cachedDepositSupplyIndex: decimal = self.liquidityAccounts[msg.sender].depositSupplyIndex
    cachedTimestamp: decimal = convert(block.timestamp, decimal)

    self.lastCheckpointTime = cachedTimestamp

    depositDecimal: decimal = convert(_deposit_amount, decimal) / cachedMantissa
    accruedAmount: decimal = DECIMAL_ZERO

    self.tokenHandle.transferFrom(msg.sender, self, convert(depositDecimal * cachedMantissa, uint256))
    
    if cachedDepositSupplyIndex != DECIMAL_ZERO:
        accruedAmount = max(((self.liquidityAccounts[msg.sender].amount * cachedSupplyIndex) / cachedDepositSupplyIndex), DECIMAL_ZERO)

    newAccountLiquidity: decimal = depositDecimal + accruedAmount

    self.liquidityAccounts[msg.sender].amount = newAccountLiquidity
    self.liquidityAccounts[msg.sender].lastDepositTime = cachedTimestamp
    self.liquidityAccounts[msg.sender].depositSupplyIndex = max(cachedSupplyIndex, DECIMAL_ZERO)
    self.totalLiquidity += depositDecimal
    self.totalDeposits += depositDecimal

@external
def removeLiquidity(
        _withdraw_amount: uint256
    ):

    assert _withdraw_amount > 0
    assert convert(block.timestamp, decimal) - self.liquidityAccounts[msg.sender].lastDepositTime >= MIN_DEPOSIT_TIME
    
    self.accrueProtocolCashflowAndUpdateActiveCollateral(True)
    self.lastCheckpointTime = convert(block.timestamp, decimal)

    cachedSupplyIndex: decimal = self.supplyIndex
    cachedMantissa: decimal = self.mantissa
    cachedTotalLiquidity: decimal = self.totalLiquidity
    cachedDepositSupplyIndex: decimal = self.liquidityAccounts[msg.sender].depositSupplyIndex

    newAccountValue: decimal = DECIMAL_ZERO
    if cachedDepositSupplyIndex != DECIMAL_ZERO:
        newAccountValue = (self.liquidityAccounts[msg.sender].amount * cachedSupplyIndex) / cachedDepositSupplyIndex

    withdrawAmount: decimal = DECIMAL_ZERO
    if _withdraw_amount == MAX_UINT256:
        withdrawAmount = newAccountValue
    else:
        withdrawAmount = convert(_withdraw_amount,decimal) / cachedMantissa
    
    assert withdrawAmount <= newAccountValue
    assert cachedTotalLiquidity >= withdrawAmount
    assert cachedTotalLiquidity - withdrawAmount >= self.activeCollateral

    self.tokenHandle.transfer(msg.sender, convert(withdrawAmount * cachedMantissa, uint256))

    self.liquidityAccounts[msg.sender].amount = newAccountValue - withdrawAmount
    self.liquidityAccounts[msg.sender].lastDepositTime = convert(block.timestamp, decimal)
    self.liquidityAccounts[msg.sender].depositSupplyIndex = max(cachedSupplyIndex, DECIMAL_ZERO)
    self.totalLiquidity -= withdrawAmount
    self.totalDeposits -= withdrawAmount

@external
def openSwap(
        _notional_amount: uint256,
        _swap_type: String[4]
    ):

    assert self.isPaused == False
    assert _notional_amount > 0

    self.accrueProtocolCashflowAndUpdateActiveCollateral(True)

    cachedMantissa: decimal = self.mantissa
    cachedSwapDuration: decimal = self.swapDuration
    cachedTimestamp: decimal = convert(block.timestamp, decimal)
    cachedSwapNumber: uint256 = self.swapNumbers[msg.sender]

    notionalAmount: decimal = convert(_notional_amount, decimal) / cachedMantissa
    self.lastCheckpointTime = cachedTimestamp
    
    swapFixedRate: decimal = DECIMAL_ZERO
    userCollateral: decimal = DECIMAL_ZERO
    if keccak256(_swap_type) == keccak256("pFix"):
        cachedNotionalReceivingFixed: decimal = self.notionalReceivingFixed
        swapFixedRate = convert(self.getRate("pFix", _notional_amount), decimal) * CONTRACT_PRECISION
        newFixedToReceive: decimal = (swapFixedRate * cachedSwapDuration * notionalAmount) / DAYS_IN_YEAR
        newMaxFloatToPay:decimal = (notionalAmount * self.maxPayoutRate * cachedSwapDuration) / DAYS_IN_YEAR

        assert self.activeCollateral + newMaxFloatToPay - newFixedToReceive < self.totalLiquidity

        self.avgFixedRateReceiving = (self.avgFixedRateReceiving * cachedNotionalReceivingFixed + notionalAmount * swapFixedRate) / (cachedNotionalReceivingFixed + notionalAmount)
        self.notionalReceivingFixed = cachedNotionalReceivingFixed + notionalAmount
        self.notionalPayingFloat += notionalAmount
        self.fixedToReceive += newFixedToReceive
        self.notionalDaysPayingFloat += notionalAmount * cachedSwapDuration

        userCollateral = (notionalAmount * cachedSwapDuration * swapFixedRate) / DAYS_IN_YEAR

        self.tokenHandle.transferFrom(msg.sender, self, convert(userCollateral * cachedMantissa, uint256))
    elif keccak256(_swap_type) == keccak256("rFix"):
        cachedNotionalPayingFixed: decimal = self.notionalPayingFixed
        swapFixedRate = convert(self.getRate("rFix", _notional_amount), decimal) * CONTRACT_PRECISION
        newFixedToPay: decimal = (swapFixedRate * cachedSwapDuration * notionalAmount) / DAYS_IN_YEAR
        newMinFloatToReceive: decimal = (self.minPayoutRate * cachedSwapDuration * notionalAmount) / DAYS_IN_YEAR

        assert self.activeCollateral + newFixedToPay - newMinFloatToReceive < self.totalLiquidity

        self.avgFixedRatePaying = (self.avgFixedRatePaying * cachedNotionalPayingFixed + notionalAmount * swapFixedRate) / (cachedNotionalPayingFixed + notionalAmount)
        self.notionalPayingFixed = cachedNotionalPayingFixed + notionalAmount
        self.notionalReceivingFloat += notionalAmount
        self.fixedToPay += newFixedToPay
        self.notionalDaysReceivingFloat += notionalAmount * cachedSwapDuration

        userCollateral = (notionalAmount * cachedSwapDuration * self.maxPayoutRate) / DAYS_IN_YEAR

        self.tokenHandle.transferFrom(msg.sender, self, convert(userCollateral * cachedMantissa, uint256))

    if keccak256(_swap_type) == keccak256("pFix") or keccak256(_swap_type) == keccak256("rFix"):
        swapKey: bytes32 = keccak256(concat(convert(msg.sender, bytes32), convert(cachedSwapNumber, bytes32)))

        self.swaps[swapKey].swapType = _swap_type
        self.swaps[swapKey].notional = notionalAmount
        self.swaps[swapKey].initTime = cachedTimestamp
        self.swaps[swapKey].swapRate = swapFixedRate
        self.swaps[swapKey].owner = msg.sender
        self.swaps[swapKey].initIndex = self.lastBorrowIndex
        self.swaps[swapKey].userCollateral = userCollateral

        self.swapNumbers[msg.sender] = cachedSwapNumber + 1

        self.metricsHandle.updateMetrics(
            _swap_type,
            convert(notionalAmount / CONTRACT_PRECISION, int128),
            convert(userCollateral / CONTRACT_PRECISION, int128),
        )


@external
def closeSwap(
        _swap_key: bytes32
    ):

    if self.swaps[_swap_key].isClosed == False:
        self.accrueProtocolCashflowAndUpdateActiveCollateral(True)

        cachedSwapDuration: decimal = self.swapDuration
        cachedCloseSwapOverride: bool = self.closeSwapOverride
        cachedNotionalReceivingFixed: decimal = self.notionalReceivingFixed
        cachedSwapNotional: decimal = self.swaps[_swap_key].notional
        cachedSwapRate: decimal = self.swaps[_swap_key].swapRate
        cachedSwapType: String[4] = self.swaps[_swap_key].swapType
        cachedSwapUserCollateral: decimal = self.swaps[_swap_key].userCollateral
        cachedSwapInitTime: decimal = self.swaps[_swap_key].initTime
        cachedSwapInitIndex: decimal = self.swaps[_swap_key].initIndex
        cachedNotionalPayingFixed: decimal = self.notionalPayingFixed
        cachedMantissa: decimal = self.mantissa
        cachedMinPayoutRate: decimal = self.minPayoutRate
        cachedTimestamp: decimal = convert(block.timestamp, decimal)

        newBorrowIndex:decimal = self.lastBorrowIndex
        liquidationEnd: decimal = cachedSwapInitTime + (cachedSwapDuration * SECONDS_PER_DAY) + (self.closePeriodInDays * SECONDS_PER_DAY)
        swapLength: decimal = cachedTimestamp - cachedSwapInitTime

        if cachedCloseSwapOverride == False:
            assert swapLength / SECONDS_PER_DAY >= cachedSwapDuration

        lateDays:decimal = (swapLength / SECONDS_PER_DAY) - cachedSwapDuration 

        if keccak256(cachedSwapType) == keccak256("pFix"):
            newNotionalReceiving:decimal = cachedNotionalReceivingFixed - cachedSwapNotional

            if newNotionalReceiving == DECIMAL_ZERO:
                self.avgFixedRateReceiving = DECIMAL_ZERO
            else:
                self.avgFixedRateReceiving = max(((self.avgFixedRateReceiving * cachedNotionalReceivingFixed - cachedSwapRate * cachedSwapNotional) / newNotionalReceiving), DECIMAL_ZERO)

            self.notionalReceivingFixed = max(self.notionalReceivingFixed - cachedSwapNotional, DECIMAL_ZERO)
            self.notionalPayingFloat -= max((self.notionalPayingFloat - ((cachedSwapNotional * newBorrowIndex) / cachedSwapInitIndex)), DECIMAL_ZERO)
            self.fixedToReceive = max((self.fixedToReceive + ((cachedSwapNotional * cachedSwapRate * lateDays) / DAYS_IN_YEAR)), DECIMAL_ZERO)
            self.notionalDaysPayingFloat = max((self.notionalDaysPayingFloat + (cachedSwapNotional * lateDays)), DECIMAL_ZERO)

        elif keccak256(cachedSwapType) == keccak256("rFix"):
            newNotionalPaying:decimal = cachedNotionalPayingFixed - cachedSwapNotional

            if newNotionalPaying == DECIMAL_ZERO:
                self.avgFixedRatePaying = DECIMAL_ZERO
            else:
                self.avgFixedRatePaying = max(((self.avgFixedRatePaying * cachedNotionalPayingFixed - cachedSwapRate * cachedSwapNotional) / newNotionalPaying), DECIMAL_ZERO)

            self.notionalPayingFixed = max((self.notionalPayingFixed - cachedSwapNotional), DECIMAL_ZERO)
            self.notionalReceivingFloat = max((self.notionalReceivingFloat - ((cachedSwapNotional * newBorrowIndex) / cachedSwapInitIndex)), DECIMAL_ZERO)
            self.fixedToPay = max((self.fixedToPay + ((cachedSwapNotional * cachedSwapRate * lateDays) / DAYS_IN_YEAR)), DECIMAL_ZERO)
            self.notionalDaysReceivingFloat += max((self.notionalDaysReceivingFloat + (cachedSwapNotional * lateDays)), DECIMAL_ZERO)

        fixedLeg:decimal = (cachedSwapNotional * cachedSwapRate * cachedSwapDuration) / DAYS_IN_YEAR
        floatLeg: decimal = DECIMAL_ZERO

        swapFloatRate: decimal = DECIMAL_ZERO
        if newBorrowIndex / cachedSwapInitIndex == 1.0:
            swapFloatRate = convert(self.calculatorHandle.getBorrowApy(), decimal) / ETH_PRECISION
            floatLeg = (cachedSwapNotional * swapFloatRate * cachedSwapDuration) / DAYS_IN_YEAR
        else:
            swapFloatRate = (newBorrowIndex / cachedSwapInitIndex - 1.0)
            floatLeg = cachedSwapNotional * swapFloatRate

        if cachedTimestamp <= liquidationEnd:
            if keccak256(cachedSwapType) == keccak256("pFix"):
                userProfit:decimal = floatLeg - fixedLeg
                ammCollateral: decimal = (cachedSwapNotional * cachedSwapDuration * self.maxPayoutRate) / DAYS_IN_YEAR
                amountToSend: decimal = DECIMAL_ZERO

                if userProfit > ammCollateral:
                    amountToSend = ammCollateral
                else:
                    amountToSend = userProfit

                if cachedCloseSwapOverride == True:
                    self.tokenHandle.transfer(self.swaps[_swap_key].owner, convert(cachedSwapUserCollateral * cachedMantissa, uint256))
                elif (amountToSend + cachedSwapUserCollateral) * cachedMantissa > DECIMAL_ZERO:
                    self.tokenHandle.transfer(self.swaps[_swap_key].owner, convert((amountToSend + cachedSwapUserCollateral) * cachedMantissa, uint256))

            elif keccak256(cachedSwapType) == keccak256("rFix"):
                if swapFloatRate < cachedMinPayoutRate:
                    floatLeg = (cachedSwapNotional * cachedMinPayoutRate * cachedSwapDuration) / DAYS_IN_YEAR

                userProfit: decimal = fixedLeg - floatLeg
                ammCollateral: decimal = (cachedSwapNotional * cachedSwapDuration * cachedSwapRate) / DAYS_IN_YEAR
                amountToSend: decimal = DECIMAL_ZERO

                if userProfit > ammCollateral:
                    amountToSend = ammCollateral
                else:
                    amountToSend = userProfit

                if cachedCloseSwapOverride == True:
                    self.tokenHandle.transfer(self.swaps[_swap_key].owner, convert(cachedSwapUserCollateral * cachedMantissa, uint256))
                elif ((amountToSend + cachedSwapUserCollateral) * cachedMantissa > DECIMAL_ZERO):
                    self.tokenHandle.transfer(self.swaps[_swap_key].owner, convert((amountToSend + cachedSwapUserCollateral) * cachedMantissa, uint256))

        self.swaps[_swap_key].isClosed = True
        self.lastCheckpointTime = cachedTimestamp

@external
@view
def getState() -> State:

    return State({
        avgFixedRateReceiving: convert(self.avgFixedRateReceiving / CONTRACT_PRECISION, int128),
        avgFixedRatePaying: convert(self.avgFixedRatePaying / CONTRACT_PRECISION, int128),
        totalLiquidity: convert(self.totalLiquidity / CONTRACT_PRECISION, int128),
        fixedToPay: convert(self.fixedToPay / CONTRACT_PRECISION, int128),
        fixedToReceive: convert(self.fixedToReceive / CONTRACT_PRECISION, int128),
        activeCollateral: convert(self.activeCollateral / CONTRACT_PRECISION, int128),
        totalDeposits: convert(self.totalDeposits / CONTRACT_PRECISION, int128),
        swapDuration: convert(self.swapDuration / CONTRACT_PRECISION, int128),
        rateFactor: convert(self.rateFactor / CONTRACT_PRECISION, int128),
        yOffset: convert(self.yOffset / CONTRACT_PRECISION, int128),
        slopeFactor: convert(self.slopeFactor / CONTRACT_PRECISION, int128),
        rateFactorSensitivity: convert(self.rateFactorSensitivity / CONTRACT_PRECISION, int128),
        feeBase: convert(self.feeBase / CONTRACT_PRECISION, int128),
        feeSensitivity: convert(self.feeSensitivity / CONTRACT_PRECISION, int128),
        rateRange: convert(self.rateRange / CONTRACT_PRECISION, int128),
        minPayoutRate: convert(self.minPayoutRate / CONTRACT_PRECISION, int128),
        maxPayoutRate: convert(self.maxPayoutRate / CONTRACT_PRECISION, int128)
    })

@external
@view
def getAccount(
        _liquidity_account: address
    ) -> LiquidityAccount128:

    return LiquidityAccount128({
        amount: convert(self.liquidityAccounts[_liquidity_account].amount / CONTRACT_PRECISION, int128),
        lastDepositTime: convert(self.liquidityAccounts[_liquidity_account].lastDepositTime / CONTRACT_PRECISION, int128),
        depositSupplyIndex: convert(self.liquidityAccounts[_liquidity_account].depositSupplyIndex / CONTRACT_PRECISION, int128)
    })

@external
@view
def getSwap(
        _swap_key: bytes32
    ) -> Swap128:

    return Swap128({
        notional: convert(self.swaps[_swap_key].notional * self.mantissa, int128),
        initTime: convert(self.swaps[_swap_key].initTime / CONTRACT_PRECISION, int128),
        swapRate: convert(self.swaps[_swap_key].swapRate / CONTRACT_PRECISION, int128),
        initIndex: convert(self.swaps[_swap_key].initIndex / CONTRACT_PRECISION, int128),
        userCollateral: convert(self.swaps[_swap_key].userCollateral / CONTRACT_PRECISION, int128),
        isClosed: self.swaps[_swap_key].isClosed
    })

@external
@view
def getSwapType(
        _swap_key: bytes32
    ) -> String[4]:
    
    return self.swaps[_swap_key].swapType
# Created by interfinex.io
# - The Greeks

@internal
def safeTransferFrom(_token: address, _from: address, _to: address, _value: uint256) -> bool:
    _response: Bytes[32] = raw_call(
        _token,
        concat(
            method_id("transferFrom(address,address,uint256)"),
            convert(_from, bytes32),
            convert(_to, bytes32),
            convert(_value, bytes32)
        ),
        max_outsize=32
    )

    if len(_response) > 0:
        assert convert(_response, bool), "Token transferFrom failed!"

    return True

@internal
def safeApprove(_token: address, _spender: address, _value: uint256) -> bool:
    _response: Bytes[32] = raw_call(
        _token,
        concat(
            method_id("approve(address,uint256)"),
            convert(_spender, bytes32),
            convert(_value, bytes32)
        ),
        max_outsize=32
    )

    if len(_response) > 0:
        assert convert(_response, bool), "Token approval failed!"

    return True

@internal
def safeTransfer(_token: address, _to: address, _value: uint256) -> bool:
    _response: Bytes[32] = raw_call(
        _token,
        concat(
            method_id("transfer(address,uint256)"),
            convert(_to, bytes32),
            convert(_value, bytes32)
        ),
        max_outsize=32
    )

    if len(_response) > 0:
        assert convert(_response, bool), "Token approval failed!"

    return True

interface MarginFactory:
    def pair_to_margin_market(assetTokenContract: address, collateralTokenContract: address) -> address: nonpayable


interface MarginMarket:
    def deposit(_amount: uint256) -> uint256: nonpayable
    def liquidityToken() -> address: view
    def withdraw(_liquidityTokenAmount: uint256) -> uint256: nonpayable
    def increasePosition(
        _totalMarginAmount: uint256, 
        _borrowAmount: uint256, 
        minCollateralAmount: uint256, 
        maxCollateralAmount: uint256, 
        deadline: uint256, 
        useIfex: bool,
        account: address
    ) -> uint256: nonpayable
    def closePosition(
        minAssetAmount: uint256, 
        maxAssetAmount: uint256, 
        deadline: uint256, 
        useIfex: bool, 
        account: address
    ): nonpayable

interface ERC20:
    def approve(_spender : address, _value : uint256) -> bool: nonpayable
    def transferFrom(_from : address, _to : address, _value : uint256) -> bool: nonpayable    
    def allowance(_owner: address, _spender: address) -> uint256: view
    def balanceOf(_account: address) -> uint256: view
    def transfer(_to: address, _value: uint256): nonpayable

interface WrappedEther:
    def deposit(): payable
    def withdraw(wad: uint256): nonpayable

wrappedEtherContract: public(address)
marginFactoryContract: public(address)

isInitialised: public(bool)

@internal
def approveContract(tokenContract: address, exchangeContract: address):
    assetAllowance: uint256 = ERC20(tokenContract).allowance(self, exchangeContract)
    if assetAllowance < MAX_UINT256 / 2:
        ERC20(tokenContract).approve(exchangeContract, MAX_UINT256)

@external
@payable
def __default__():
    return

@external
def initialize(_wrappedEtherContract: address, _marginFactoryContract: address, ):
    assert self.isInitialised == False, "Already initialised"
    self.isInitialised = True
    self.wrappedEtherContract = _wrappedEtherContract
    self.marginFactoryContract = _marginFactoryContract

@external
@payable
def deposit(assetTokenContract: address):
    marginMarketContract: address = MarginFactory(self.marginFactoryContract).pair_to_margin_market(
        self.wrappedEtherContract,
        assetTokenContract
    )
    liquidityTokenContract: address = MarginMarket(marginMarketContract).liquidityToken()

    self.approveContract(self.wrappedEtherContract, marginMarketContract)
    WrappedEther(self.wrappedEtherContract).deposit(value=msg.value)
    MarginMarket(marginMarketContract).deposit(msg.value)
    ERC20(liquidityTokenContract).transfer(msg.sender, ERC20(liquidityTokenContract).balanceOf(self))

@external
def withdraw(assetTokenContract: address, liquidityTokenAmount: uint256):
    marginMarketContract: address = MarginFactory(self.marginFactoryContract).pair_to_margin_market(
        self.wrappedEtherContract,
        assetTokenContract
    )
    liquidityTokenContract: address = MarginMarket(marginMarketContract).liquidityToken()
    ERC20(liquidityTokenContract).transferFrom(msg.sender, self, liquidityTokenAmount)

    self.approveContract(liquidityTokenContract, marginMarketContract)
    MarginMarket(marginMarketContract).withdraw(liquidityTokenAmount)

    WrappedEther(self.wrappedEtherContract).withdraw(ERC20(self.wrappedEtherContract).balanceOf(self))
    send(msg.sender, self.balance)

@external
@payable
def increasePosition(
    assetTokenContract: address,
    _borrowAmount: uint256, 
    minCollateralAmount: uint256, 
    maxCollateralAmount: uint256, 
    deadline: uint256, 
    useIfex: bool
) -> uint256:
    marginMarketContract: address = MarginFactory(self.marginFactoryContract).pair_to_margin_market(
        self.wrappedEtherContract,
        assetTokenContract
    )

    _totalMarginAmount: uint256 = msg.value
    self.approveContract(self.wrappedEtherContract, marginMarketContract)
    WrappedEther(self.wrappedEtherContract).deposit(value=msg.value)
    
    collateralAmount: uint256 = MarginMarket(marginMarketContract).increasePosition(
        _totalMarginAmount, 
        _borrowAmount, 
        minCollateralAmount, 
        maxCollateralAmount, 
        deadline, 
        useIfex,
        msg.sender
    )

    return collateralAmount

@external
def closePosition(
    assetTokenContract: address,
    minAssetAmount: uint256, 
    maxAssetAmount: uint256, 
    deadline: uint256, 
    useIfex: bool
): 
    marginMarketContract: address = MarginFactory(self.marginFactoryContract).pair_to_margin_market(
        self.wrappedEtherContract,
        assetTokenContract
    )

    MarginMarket(marginMarketContract).closePosition(
        minAssetAmount,
        maxAssetAmount,
        deadline,
        useIfex,
        msg.sender
    )

    wethBalance: uint256 = ERC20(self.wrappedEtherContract).balanceOf(self)
    if wethBalance > 0:
        WrappedEther(self.wrappedEtherContract).withdraw(wethBalance)
        send(msg.sender, self.balance)
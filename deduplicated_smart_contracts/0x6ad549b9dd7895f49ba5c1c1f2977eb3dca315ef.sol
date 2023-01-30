# Created by interfinex.io
# - The Greeks

interface MarginMarket:
    def initialize(
        _assetToken: address, 
        _collateralToken: address, 
        _dividend_erc20_template: address, 
        _ifex_token: address,
        _swap_factory: address
    ) -> bool: nonpayable
    def liquidityToken() -> address: view

event NewMarginMarket:
    creator: indexed(address)
    margin_market_address: indexed(address)
    assetToken: address
    collateralToken: address

id_count: public(uint256)
id_to_margin_market: public(HashMap[uint256, address])
pair_to_margin_market: public(HashMap[address, HashMap[address, address]])
margin_market_to_pair: public(HashMap[address, address[2]])
liquidity_token_to_pair: public(HashMap[address, address[2]])

margin_market_template: public(address)
dividend_erc20_template: public(address)
ifex_token: public(address)
swap_factory: public(address)

is_initialized: public(bool)

@external
def initialize(_margin_market_template: address, _dividend_erc20_template: address, _ifex_token: address, _swap_factory: address):
    assert self.is_initialized == False, "Factory already initialized"
    self.is_initialized = True
    self.margin_market_template = _margin_market_template
    self.dividend_erc20_template = _dividend_erc20_template
    self.ifex_token = _ifex_token
    self.swap_factory = _swap_factory
    return

@internal
def createMarket(assetToken: address, collateralToken: address, creator: address):
    # Create and init the new margin market
    margin_market: address = create_forwarder_to(self.margin_market_template)
    MarginMarket(margin_market).initialize(assetToken, collateralToken, self.dividend_erc20_template, self.ifex_token, self.swap_factory)

    # Save the contract into state to be accessed later by other functions etc.
    assert self.pair_to_margin_market[assetToken][collateralToken] == ZERO_ADDRESS, "Margin market for this pair already exists"
    new_id: uint256 = self.id_count + 1
    self.id_count = new_id
    self.id_to_margin_market[new_id] = margin_market
    self.pair_to_margin_market[assetToken][collateralToken] = margin_market
    self.margin_market_to_pair[margin_market] = [assetToken, collateralToken]

    liquidityToken: address = MarginMarket(margin_market).liquidityToken()
    self.liquidity_token_to_pair[liquidityToken] = [assetToken, collateralToken]
    log NewMarginMarket(creator, margin_market, assetToken, collateralToken)

@external
def createMarketPair(_token0: address, _token1: address):
    self.createMarket(_token0, _token1, msg.sender)
    self.createMarket(_token1, _token0, msg.sender)
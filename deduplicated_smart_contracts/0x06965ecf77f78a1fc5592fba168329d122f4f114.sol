struct PriceInfo:
    price: uint256
    lastUpdate: uint256

contract ERC20():
    def balanceOf(_owner: address) -> uint256: constant
    def decimals() -> uint256: constant

contract DaiPriceOracle:
    def g_priceInfo() -> PriceInfo: constant

PRICE_MULTIPLIER: constant(uint256) = 100000000 # 10**8

# DAI oracle returns DAI/USD price multiplied by 10**18
MIN_DAI_PRICE: constant(uint256) = 950000000000000000 # 0.95*10**18
MAX_DAI_PRICE: constant(uint256) = 1050000000000000000 # 1.05*10**18
# DAI_ORACLE_DIVIDER = 10**18 / PRICE_MULTIPLIER
DAI_ORACLE_DIVIDER: constant(uint256) = 10000000000 # 10**10

TokenAddressUpdated: event({token_address: indexed(address), token_index: indexed(int128)})

name: public(string[16])
owner: public(address)
supportedTokens: public(address[5])
daiAddress: public(address)
daiOracleAddress: public(address)

@public
def __init__(dai_address: address, dai_oracle_address: address):
    assert dai_address != ZERO_ADDRESS
    assert dai_oracle_address != ZERO_ADDRESS

    self.daiAddress = dai_address
    self.daiOracleAddress = dai_oracle_address
    self.supportedTokens[0] = dai_address
    self.owner = msg.sender
    self.name = 'PriceOracle'
    
@public
@constant
def normalized_token_prices(token_address: address) -> uint256:
    token_price: uint256
    token_decimals: uint256 = ERC20(token_address).decimals()
    
    if token_address != self.daiAddress:
        token_price = PRICE_MULTIPLIER
    else:
        price_info: PriceInfo = DaiPriceOracle(self.daiOracleAddress).g_priceInfo()
        token_price = price_info.price
        assert token_price >= MIN_DAI_PRICE
        assert token_price <= MAX_DAI_PRICE
        token_price = token_price / DAI_ORACLE_DIVIDER    

    normalized_price: uint256 = token_price * 10**(18 - token_decimals)
    return normalized_price

@public
@constant
def poolSize(contract_address: address) -> uint256:
    token_address: address
    normalized_price: uint256
    total: uint256 = 0

    for ind in range(5):
        token_address = self.supportedTokens[ind]
        if token_address != ZERO_ADDRESS:
            contract_balance: uint256 = ERC20(token_address).balanceOf(contract_address)
            normalized_price = self.normalized_token_prices(token_address)
            total += contract_balance * normalized_price / PRICE_MULTIPLIER

    return total

@public
def updateTokenAddress(token_address: address, ind: int128) -> bool:
    assert msg.sender == self.owner

    self.supportedTokens[ind] = token_address
    log.TokenAddressUpdated(token_address, ind)

    return True
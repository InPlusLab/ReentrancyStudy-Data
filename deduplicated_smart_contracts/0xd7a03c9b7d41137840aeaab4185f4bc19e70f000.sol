contract ERC20():
    def balanceOf(_owner: address) -> uint256: constant
    def decimals() -> uint256: constant

MIN_PRICE: constant(uint256) = 1000000 # 10**6
MAX_PRICE: constant(uint256) = 100000000000000000000000000 # 10**(8 + 18)
PRICE_MULTIPLIER: constant(uint256) = 100000000 # 10**8

PriceUpdated: event({token_address: indexed(address), new_price: indexed(uint256)})
TokenAddressUpdated: event({token_address: indexed(address), token_index: indexed(int128)})

name: public(string[16])
owner: public(address)
supported_tokens: public(address[5])
normalized_token_prices: public(map(address, uint256))

@public
def __init__():
    self.owner = msg.sender
    self.name = 'PriceOracle'

@public
@constant
def poolSize(contract_address: address) -> uint256:
    token_address: address
    total: uint256 = 0

    for ind in range(5):
        token_address = self.supported_tokens[ind]
        if token_address != ZERO_ADDRESS:
            contract_balance: uint256 = ERC20(token_address).balanceOf(contract_address)
            total += contract_balance * self.normalized_token_prices[token_address] / PRICE_MULTIPLIER

    return total

@public
def updateTokenAddress(token_address: address, ind: int128) -> bool:
    assert msg.sender == self.owner

    self.supported_tokens[ind] = token_address
    log.TokenAddressUpdated(token_address, ind)

    return True

@public
# Token price is as uint256:
# normalized_usd_price = usd_price * PRICE_MULTIPLIER * 10**(stablecoinswap.decimals - token.decimals)
# Example: USD price for USDC = $0.97734655, normalized_usd_price = 97734655000000000000
def updatePrice(token_address: address, normalized_usd_price: uint256) -> bool:
    assert msg.sender == self.owner
    assert MIN_PRICE <= normalized_usd_price and normalized_usd_price <= MAX_PRICE

    self.normalized_token_prices[token_address] = normalized_usd_price
    log.PriceUpdated(token_address, normalized_usd_price)

    return True
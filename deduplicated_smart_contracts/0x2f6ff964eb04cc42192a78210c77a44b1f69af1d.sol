contract ERC20():
    def transfer(_to: address, _value: uint256) -> bool: modifying
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: modifying
    def balanceOf(_owner: address) -> uint256: constant
    def allowance(_owner: address, _spender: address) -> uint256: constant
    def decimals() -> uint256: constant

contract PriceOracle():
    def poolSize(contract_address: address) -> uint256: constant
    def normalized_token_prices(token_address: address) -> uint256: constant

TOKEN_PRICE_MULTIPLIER: constant(uint256) = 100000000
FEE_MULTIPLIER: constant(uint256) = 100000

# ERC20 events
Transfer: event({_from: indexed(address), _to: indexed(address), _value: uint256})
Approval: event({_owner: indexed(address), _spender: indexed(address), _value: uint256})

OwnershipTransferred: event({previous_owner: indexed(address), new_owner: indexed(address)})
LiquidityAdded: event({provider: indexed(address), amount: indexed(uint256)})
LiquidityRemoved: event({provider: indexed(address), amount: indexed(uint256)})
Trade: event({input_token: indexed(address), output_token: indexed(address), input_amount: indexed(uint256)})
PermissionUpdated: event({name: indexed(string[32]), value: indexed(bool)})
FeeUpdated: event({name: indexed(string[32]), value: indexed(decimal)})
PriceOracleAddressUpdated: event({new_address: indexed(address)})
Payment: event({amount: uint256(wei), _from: indexed(address)})

name: public(string[32])                                 # Stablecoinswap
owner: public(address)                                   # contract owner
decimals: public(uint256)                                # 18
totalSupply: public(uint256)                             # total number of contract tokens in existence
balanceOf: public(map(address, uint256))                 # balance of an address
allowance: public(map(address, map(address, uint256)))   # allowance of one address on another
inputTokens: public(map(address, bool))                  # addresses of the ERC20 tokens allowed to transfer into this contract
outputTokens: public(map(address, bool))                 # addresses of the ERC20 tokens allowed to transfer out of this contract
permissions: public(map(string[32], bool))               # pause / resume contract functions
feesInt: map(string[32], uint256)                        # trade / pool fees multiplied by FEE_MULTIPLIER
priceOracleAddress: public(address)                      # address of price oracle

@public
def __init__(token_addresses: address[3], price_oracle_addr: address):
    assert price_oracle_addr != ZERO_ADDRESS

    self.owner = msg.sender
    self.name = "Stablecoinswap"
    self.decimals = 18
    self.permissions["tradingAllowed"] = True
    self.permissions["liquidityAddingAllowed"] = True
    self.permissions["liquidityRemovingAllowed"] = True

    for i in range(3):
        assert token_addresses[i] != ZERO_ADDRESS
        self.inputTokens[token_addresses[i]] = True
        self.outputTokens[token_addresses[i]] = True

    self.feesInt['tradeFee'] = 200
    self.feesInt['ownerFee'] = 100

    self.priceOracleAddress = price_oracle_addr

@private
@constant
def tokenPrice(token_address: address) -> uint256:
    token_price: uint256 = PriceOracle(self.priceOracleAddress).normalized_token_prices(token_address)
    assert token_price > 0

    return token_price

# Deposit erc20 token
@public
def addLiquidity(token_address: address, erc20_token_amount: uint256, deadline: timestamp) -> bool:
    assert self.inputTokens[token_address]
    assert deadline > block.timestamp and erc20_token_amount > 0
    assert self.permissions["liquidityAddingAllowed"]
    assert ERC20(token_address).balanceOf(msg.sender) >= erc20_token_amount
    assert ERC20(token_address).allowance(msg.sender, self) >= erc20_token_amount

    token_price: uint256 = self.tokenPrice(token_address)
    # It's better to divide at the very end for a higher precision
    new_liquidity: uint256 = token_price * erc20_token_amount / TOKEN_PRICE_MULTIPLIER
    if self.totalSupply > 0:
        new_liquidity = new_liquidity * self.totalSupply / PriceOracle(self.priceOracleAddress).poolSize(self)
    else:
        assert new_liquidity >= 1000000000

    self.balanceOf[msg.sender] += new_liquidity
    self.totalSupply += new_liquidity

    # Can't assert the result directly: https://github.com/ethereum/vyper/issues/1468
    transfer_from_result: bool = ERC20(token_address).transferFrom(msg.sender, self, erc20_token_amount)
    assert transfer_from_result

    log.LiquidityAdded(msg.sender, new_liquidity)

    return True

# Withdraw erc20 token
@public
def removeLiquidity(token_address: address, stableswap_token_amount: uint256, deadline: timestamp) -> bool:
    assert self.outputTokens[token_address]
    assert stableswap_token_amount > 0 and deadline > block.timestamp
    assert self.balanceOf[msg.sender] >= stableswap_token_amount
    assert self.permissions["liquidityRemovingAllowed"]
    assert self.totalSupply > 0

    token_price: uint256 = self.tokenPrice(token_address)
    pool_size: uint256 = PriceOracle(self.priceOracleAddress).poolSize(self)
    # erc20_token_amount = stableswapt_token_amount * pool_size / totalSupply / token_price * TOKEN_PRICE_MULTIPLIER
    # It's better to divide at the very end for a higher precision
    erc20_token_amount: uint256 = stableswap_token_amount * pool_size * TOKEN_PRICE_MULTIPLIER / token_price / self.totalSupply

    ownerFee: uint256 = 0

    if msg.sender != self.owner:
        ownerFee = stableswap_token_amount * self.feesInt['ownerFee'] / FEE_MULTIPLIER
        multiplier_after_fees: uint256 = FEE_MULTIPLIER - self.feesInt['ownerFee'] - self.feesInt['tradeFee']
        erc20_token_amount = erc20_token_amount * multiplier_after_fees / FEE_MULTIPLIER

    self.balanceOf[msg.sender] -= stableswap_token_amount
    self.balanceOf[self.owner] += ownerFee
    self.totalSupply -= stableswap_token_amount - ownerFee

    # Can't assert the result directly: https://github.com/ethereum/vyper/issues/1468
    transfer_result: bool = ERC20(token_address).transfer(msg.sender, erc20_token_amount)
    assert transfer_result

    log.LiquidityRemoved(msg.sender, stableswap_token_amount)

    return True

# Trade one erc20 token for another
@public
def swapTokens(input_token: address, output_token: address, erc20_input_amount: uint256, erc20_min_output_amount: uint256, deadline: timestamp) -> bool:
    assert self.inputTokens[input_token] and self.outputTokens[output_token]
    assert erc20_input_amount > 0 and erc20_min_output_amount > 0
    assert deadline > block.timestamp
    assert self.permissions["tradingAllowed"]
    assert ERC20(input_token).balanceOf(msg.sender) >= erc20_input_amount
    assert ERC20(input_token).allowance(msg.sender, self) >= erc20_input_amount

    input_token_price: uint256 = self.tokenPrice(input_token)
    output_token_price: uint256 = self.tokenPrice(output_token)

    # contract_token_amount is an equivalent of an input multiplied by TOKEN_PRICE_MULTIPLIER
    contract_token_amount: uint256 = erc20_input_amount * input_token_price
    tradeFee: uint256 = contract_token_amount * self.feesInt['tradeFee'] / FEE_MULTIPLIER
    ownerFee: uint256 = contract_token_amount * self.feesInt['ownerFee'] / FEE_MULTIPLIER
    contract_token_amount -= tradeFee + ownerFee

    tradeFee /= TOKEN_PRICE_MULTIPLIER
    ownerFee /= TOKEN_PRICE_MULTIPLIER
    pool_size_after_swap: uint256 = PriceOracle(self.priceOracleAddress).poolSize(self) + tradeFee
    new_owner_shares: uint256 = self.totalSupply * ownerFee / pool_size_after_swap

    erc20_output_amount: uint256 = contract_token_amount / output_token_price
    assert erc20_output_amount >= erc20_min_output_amount

    self.balanceOf[self.owner] += new_owner_shares
    self.totalSupply += new_owner_shares

    # Can't assert the result directly: https://github.com/ethereum/vyper/issues/1468
    transfer_from_result: bool = ERC20(input_token).transferFrom(msg.sender, self, erc20_input_amount)
    assert transfer_from_result
    transfer_result: bool = ERC20(output_token).transfer(msg.sender, erc20_output_amount)
    assert transfer_result

    log.Trade(input_token, output_token, erc20_input_amount)

    return True

@public
def updateInputToken(token_address: address, allowed: bool) -> bool:
    assert msg.sender == self.owner
    assert not self.inputTokens[token_address] == allowed
    self.inputTokens[token_address] = allowed
    return True

@public
def updateOutputToken(token_address: address, allowed: bool) -> bool:
    assert msg.sender == self.owner
    assert not self.outputTokens[token_address] == allowed
    self.outputTokens[token_address] = allowed
    return True

@public
def updatePermission(permission_name: string[32], value: bool) -> bool:
    assert msg.sender == self.owner
    self.permissions[permission_name] = value
    log.PermissionUpdated(permission_name, value)
    return True

# Return share of total liquidity belonging to the user
@public
@constant
def poolOwnership(user_address: address) -> decimal:
    user_balance: decimal = convert(self.balanceOf[user_address], decimal)
    total_liquidity: decimal = convert(self.totalSupply, decimal)
    share: decimal = user_balance / total_liquidity
    return share

@public
def transferOwnership(new_owner: address) -> bool:
    assert new_owner != ZERO_ADDRESS
    assert msg.sender == self.owner
    self.owner = new_owner
    log.OwnershipTransferred(self.owner, new_owner)
    return True

@public
def updateFee(fee_name: string[32], value: decimal) -> bool:
    assert msg.sender == self.owner
    self.feesInt[fee_name] = convert(floor(value * convert(FEE_MULTIPLIER, decimal)), uint256)
    log.FeeUpdated(fee_name, value)
    return True

@public
@constant
def fees(fee_name: string[32]) -> decimal:
    return convert(self.feesInt[fee_name], decimal) / convert(FEE_MULTIPLIER, decimal)

@public
def updatePriceOracleAddress(new_address: address) -> bool:
    assert msg.sender == self.owner
    self.priceOracleAddress = new_address
    log.PriceOracleAddressUpdated(new_address)
    return True

# ERC-20 functions

@public
def transfer(_to: address, _value: uint256) -> bool:
    self.balanceOf[msg.sender] -= _value
    self.balanceOf[_to] += _value
    log.Transfer(msg.sender, _to, _value)
    return True

@public
def transferFrom(_from: address, _to: address, _value: uint256) -> bool:
    self.balanceOf[_from] -= _value
    self.balanceOf[_to] += _value
    self.allowance[_from][msg.sender] -= _value
    log.Transfer(_from, _to, _value)
    return True

@public
def approve(_spender: address, _value: uint256) -> bool:
    self.allowance[msg.sender][_spender] = _value
    log.Approval(msg.sender, msg.sender, _value)
    return True
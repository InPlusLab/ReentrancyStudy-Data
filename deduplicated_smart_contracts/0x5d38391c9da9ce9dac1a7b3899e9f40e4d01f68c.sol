# @version 0.2.7
from vyper.interfaces import ERC20


struct List:
    prev: uint256
    next: uint256


struct Urn:
    ink: uint256
    art: uint256


struct ProtectedLiquidity:
    provider: address
    poolToken: address
    reserveToken: address
    poolAmount: uint256
    reserveAmount: uint256
    reserveRateN: uint256
    reserveRateD: uint256
    time: uint256


interface Vault:
    def balanceOf(user: address) -> uint256: view
    def getPricePerFullShare() -> uint256: view
    def activation() -> uint256: view


interface DSProxyRegistry:
    def proxies(user: address) -> address: view


interface DssCdpManager:
    def count(user: address) -> uint256: view
    def first(user: address) -> uint256: view
    def list(cdp: uint256) -> List: view
    def ilks(cdp: uint256) -> bytes32: view
    def urns(cdp: uint256) -> address: view


interface Vat:
    def urns(ilk: bytes32, user: address) -> Urn: view


interface Bancor:
    def protectedLiquidityCount(provider: address) -> uint256: view
    def protectedLiquidityId(provider: address, index: uint256) -> uint256: view
    def protectedLiquidity(_id: uint256) -> ProtectedLiquidity: view


event GuestInvited:
    guest: address


event GuestRemoved:
    guest: address


event BouncerChanged:
    bouncer: address


event BribeCostUpdated:
    bribe_cost: uint256


event BribeReceived:
    guest: address
    bouncer: address
    bribe: uint256


MIN_BAG: constant(uint256) = 10 ** 18
APE_OUT: constant(uint256) = 30 * 86400
bouncer: public(address)
guests: public(HashMap[address, bool])
bribe_cost: public(uint256)
yfi: ERC20
ygov: ERC20
yyfi: Vault
proxy_registry: DSProxyRegistry
cdp_manager: DssCdpManager
vat: Vat
ilk: bytes32
uni_pairs: address[3]
bancor: Bancor


@external
def __init__():
    self.bouncer = msg.sender
    self.bribe_cost = 25 * 10 ** 15  # 0.025 YFI life pass
    # tokens
    self.yfi = ERC20(0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e)
    self.ygov = ERC20(0xBa37B002AbaFDd8E89a1995dA52740bbC013D992)
    self.yyfi = Vault(0xBA2E7Fed597fd0E3e70f5130BcDbbFE06bB94fe1)
    # makerdao
    self.proxy_registry = DSProxyRegistry(0x4678f0a6958e4D2Bc4F1BAF7Bc52E8F3564f3fE4)
    self.cdp_manager = DssCdpManager(0x5ef30b9986345249bc32d8928B7ee64DE9435E39)
    self.vat = Vat(0x35D1b3F3D7966A1DFe207aa4514C12a259A0492B)
    yfi_a: Bytes[32] = b"YFI-A"
    self.ilk = convert(yfi_a, bytes32)
    # liquidity providers
    self.uni_pairs = [
        0x2fDbAdf3C4D5A8666Bc06645B8358ab803996E28,  # Uniswap YFI/WETH
        0x088ee5007C98a9677165D78dD2109AE4a3D04d0C,  # Sushiswap YFI/WETH
        0x41284a88D970D3552A26FaE680692ED40B34010C,  # Balancer YFI/WETH 50/50
    ]
    self.bancor = Bancor(0xf5FAB5DBD2f3bf675dE4cB76517d4767013cfB55)

    log BouncerChanged(self.bouncer)
    log BribeCostUpdated(self.bribe_cost)


@view
@internal
def yfi_in_vault(user: address) -> uint256:
    return self.yyfi.balanceOf(user) * self.yyfi.getPricePerFullShare() / 10 ** 18


@view
@internal
def yfi_in_makerdao(user: address) -> uint256:
    proxy: address = self.proxy_registry.proxies(user)
    if proxy == ZERO_ADDRESS:
        return 0
    cdp: uint256 = self.cdp_manager.first(proxy)
    urn: address = ZERO_ADDRESS
    total: uint256 = 0
    for i in range(100):
        if cdp == 0:
            break
        if self.cdp_manager.ilks(cdp) == self.ilk:
            urn = self.cdp_manager.urns(cdp)
            total += self.vat.urns(self.ilk, urn).ink        
        cdp = self.cdp_manager.list(cdp).next
    return total


@view
@internal
def yfi_in_liquidity_pools(user: address) -> uint256:
    total: uint256 = 0
    for pair in self.uni_pairs:
        total += self.yfi.balanceOf(pair) * ERC20(pair).balanceOf(user) / ERC20(pair).totalSupply()
    return total


@view
@internal
def yfi_in_bancor(user: address) -> uint256:
    total: uint256 = 0
    id: uint256 = 0
    count: uint256 = self.bancor.protectedLiquidityCount(user)
    liquidity: ProtectedLiquidity = empty(ProtectedLiquidity)
    for i in range(100):
        if i == count:
            break
        id = self.bancor.protectedLiquidityId(user, i)
        liquidity = self.bancor.protectedLiquidity(id)
        if liquidity.reserveToken == self.yfi.address:
            total += liquidity.reserveAmount
    return total


@view
@internal
def _entrance_cost(start: uint256) -> uint256:
    elapsed: uint256 = min(block.timestamp - start, APE_OUT)
    return MIN_BAG - MIN_BAG * elapsed / APE_OUT


@view
@internal
def enough_yfi(user: address, threshold: uint256) -> bool:
    # gas-optimized, exits as soon as threshold is reached
    total: uint256 = 0
    total += self.yfi.balanceOf(user)
    if total >= threshold:
        return True
    total += self.ygov.balanceOf(user)
    if total >= threshold:
        return True
    total += self.yfi_in_vault(user)
    if total >= threshold:
        return True
    total += self.yfi_in_liquidity_pools(user)
    if total >= threshold:
        return True
    total += self.yfi_in_makerdao(user)
    if total >= threshold:
        return True
    total += self.yfi_in_bancor(user)
    if total >= threshold:
        return True
    return False

# EXTERNAL FUNCTIONS

@view
@external
def min_bag() -> uint256:
    return MIN_BAG


@view
@external
def ape_out() -> uint256:
    return APE_OUT


@external
def set_guest(guest: address, invited: bool):
    """
    Invite or kick guests from the party.
    """
    assert msg.sender == self.bouncer  # dev: unauthorized
    self.guests[guest] = invited
    if invited:
        log GuestInvited(guest)
    else:
        log GuestRemoved(guest)


@external
def set_bribe_cost(new_cost: uint256):
    """
    Set bribe cost denominated in YFI.
    """
    assert msg.sender == self.bouncer  # dev: unauthorized
    self.bribe_cost = new_cost
    log BribeCostUpdated(self.bribe_cost)


@external
def set_bouncer(new_bouncer: address):
    """
    Replace bouncer role.
    """
    assert msg.sender == self.bouncer  # dev: unauthorized
    self.bouncer = new_bouncer
    log BouncerChanged(self.bouncer)


@external
def bribe_the_bouncer(guest: address = msg.sender):
    """
    Sneak into the party by bribing the bouncer.
    The pass is good for any vault that uses this guest list.
    """
    assert not self.guests[guest]  # dev: already invited
    self.yfi.transferFrom(msg.sender, self.bouncer, self.bribe_cost)
    self.guests[guest] = True

    log BribeReceived(guest, self.bouncer, self.bribe_cost)
    log GuestInvited(guest)


@view
@external
def total_yfi(user: address) -> uint256:
    """
    Total YFI in wallet, yGov, yYFI Vault, MakerDAO, Uniswap, Sushiswap, Balancer, Bancor.
    """
    return (
        self.yfi.balanceOf(user)
        + self.ygov.balanceOf(user)
        + self.yfi_in_vault(user)
        + self.yfi_in_makerdao(user)
        + self.yfi_in_liquidity_pools(user)
        + self.yfi_in_bancor(user)
    )


@view
@external
def entrance_cost(start: uint256) -> uint256:
    """
    How much productive YFI is currently needed to enter.
    """
    return self._entrance_cost(start)


@view
@external
def authorized(guest: address, amount: uint256) -> bool:
    """
    Check if a user with a bag of certain size is allowed to the party.
    """
    if self.guests[guest]:
        return True
    # NOTE: msg.sender must implement `activation()`
    start: uint256 = Vault(msg.sender).activation()
    if block.timestamp >= start + APE_OUT:
        return True
    threshold: uint256 = self._entrance_cost(start)
    return self.enough_yfi(guest, threshold)
unlockDate: public(uint256)
ifexTokenContract: public(address)
owner: public(address)

isInitialized: public(bool)

interface ERC20:
    def transfer(_to : address, _value : uint256) -> bool: nonpayable    
    def balanceOf(_owner: address) -> uint256: view

@internal
def ownable(account: address):
    assert account == self.owner, "Not owner!"

@external
def initialize(_unlockDate: uint256, _ifexTokenContract: address):
    assert self.isInitialized == False, "Vault already initialized"
    self.isInitialized = True
    self.unlockDate = _unlockDate
    self.ifexTokenContract = _ifexTokenContract
    self.owner = msg.sender

@external
def withdraw():
    self.ownable(msg.sender)
    assert block.timestamp >= self.unlockDate, "Vault is locked"
    ERC20(self.ifexTokenContract).transfer(msg.sender, ERC20(self.ifexTokenContract).balanceOf(self))

@external
def changeOwner(newOwner: address):
    self.ownable(msg.sender)
    self.owner = newOwner
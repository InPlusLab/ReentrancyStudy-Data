# Mantis Faucet by DeFi LABS
# https://defilabs.eth.link & tg: https://t.me/defilabs_community
# pria.network

interface MantisFaucet:
    def transfer(_to: address, _value: uint256) -> bool: payable

interface GetTime:
    def getBlockTime() -> uint256: view

Owner: public(address)
Airdrop_Eligibility: public(HashMap[address, bool])
Amount: public(uint256)
Contract: public(address)
Name: public(String[64])

@external
def __init__(_name: String[64]):
    self.Name = _name
    self.Owner = msg.sender
    self.Airdrop_Eligibility[msg.sender] = False
    self.Amount = 0
    self.Contract = ZERO_ADDRESS

@external
def ClaimReward() -> bool:
    assert self.Airdrop_Eligibility[msg.sender] == True, "Address not eligible."
    MantisFaucet(self.Contract).transfer(msg.sender, self.Amount)
    self.Airdrop_Eligibility[msg.sender] = False
    return True

@external
def setContract(_contract: address) -> bool:
    assert msg.sender == self.Owner
    self.Contract = _contract
    return True

@external
def setAmount(_amount: uint256) -> bool:
    assert msg.sender == self.Owner
    self.Amount = _amount
    return True

@external
def setEligible_Single(_eligibleAddy: address) -> bool:
    assert msg.sender == self.Owner
    self.Airdrop_Eligibility[_eligibleAddy] = True
    return True

@external
def remEligible_Single(_eligibleAddy: address) -> bool:
    assert msg.sender == self.Owner
    self.Airdrop_Eligibility[_eligibleAddy] = False
    return True

@external
def remEligible_Bulk(_eligibleList: address[100]) -> bool:
    assert msg.sender == self.Owner
    for addy in range (0, 100):
        if _eligibleList[addy] != ZERO_ADDRESS:
            self.Airdrop_Eligibility[_eligibleList[addy]] = False
        else:
            break
    return True

@external
def setEligible_Bulk(_eligibleList: address[100]) -> bool:
    assert msg.sender == self.Owner
    for addy in range (0, 100):
        if _eligibleList[addy] != ZERO_ADDRESS:
            self.Airdrop_Eligibility[_eligibleList[addy]] = True
        else:
            break
    return True

@external
def retrieve() -> bool:
    assert msg.sender == self.Owner
    MantisFaucet(self.Contract).transfer(msg.sender, self.Amount)
    return True

@external
def sweep():
    assert msg.sender == self.Owner
    selfdestruct(msg.sender)
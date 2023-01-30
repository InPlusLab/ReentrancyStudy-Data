interface DividendERC20:
    def distributeDividends(_value: uint256): nonpayable


interface ERC20:
    def approve(_spender : address, _value : uint256) -> bool: nonpayable
    def transfer(_to : address, _value : uint256) -> bool: nonpayable
    def balanceOf(_owner: address) -> uint256: view

struct FarmInfo:
    yieldPerBlock: uint256
    tokenContract: address
    lastBlockUpdate: uint256
    id: uint256
    marketType: uint256

event NewFarm:
    tokenContract: address
    marketType: uint256

event UpdateFarm:
    tokenContract: address
    marketType: uint256

event DeleteFarm:
    tokenContract: address
    marketType: uint256

event Harvest:
    tokenContract: address
    marketType: uint256
    yieldAmount: uint256

ifexTokenContract: public(address)
owner: public(address)

farmId: public(uint256)
tokenToFarmInfo: public(HashMap[address, FarmInfo])
idToFarmTokenAddress: public(HashMap[uint256, address])

isInitialized: public(bool)

@internal
def ownable(account: address):
    assert account == self.owner, "Invalid permission"

@external
def initialize(_ifexTokenContract: address):
    assert self.isInitialized == False, "Already initialized"
    self.ifexTokenContract = _ifexTokenContract
    self.owner = msg.sender
    self.isInitialized = True

@external
def addFarm(tokenContract: address, yieldPerBlock: uint256, marketType: uint256):
    self.ownable(msg.sender)
    self.farmId += 1

    farmInfo: FarmInfo = empty(FarmInfo)
    farmInfo.yieldPerBlock = yieldPerBlock
    farmInfo.tokenContract = tokenContract
    farmInfo.id = self.farmId
    farmInfo.lastBlockUpdate = block.number
    farmInfo.marketType = marketType

    self.tokenToFarmInfo[tokenContract] = farmInfo
    self.idToFarmTokenAddress[farmInfo.id] = farmInfo.tokenContract

    ERC20(self.ifexTokenContract).approve(tokenContract, MAX_UINT256)
    log NewFarm(tokenContract, marketType)

@external
def deleteFarm(tokenContract: address):
    self.ownable(msg.sender)
    
    farmToDelete: FarmInfo = self.tokenToFarmInfo[tokenContract]
    self.tokenToFarmInfo[farmToDelete.tokenContract] = empty(FarmInfo)
    self.idToFarmTokenAddress[farmToDelete.id] = ZERO_ADDRESS
    log DeleteFarm(tokenContract, farmToDelete.marketType)

@external
def updateFarm(tokenContract: address, yieldPerBlock: uint256):
    self.ownable(msg.sender)

    farmToUpdate: FarmInfo = self.tokenToFarmInfo[tokenContract]
    farmToUpdate.yieldPerBlock = yieldPerBlock

    self.tokenToFarmInfo[tokenContract] = farmToUpdate
    self.idToFarmTokenAddress[farmToUpdate.id] = farmToUpdate.tokenContract
    log UpdateFarm(tokenContract, farmToUpdate.marketType)

@external
def harvest(tokenContract: address):
    assert msg.sender == tx.origin
    farmToHarvest: FarmInfo = self.tokenToFarmInfo[tokenContract]

    blockDelta: uint256 = block.number - farmToHarvest.lastBlockUpdate
    if blockDelta > 0 and farmToHarvest.tokenContract == tokenContract:
        yieldAmount: uint256 = farmToHarvest.yieldPerBlock * blockDelta
        DividendERC20(farmToHarvest.tokenContract).distributeDividends(yieldAmount)
        farmToHarvest.lastBlockUpdate = block.number
        self.tokenToFarmInfo[farmToHarvest.tokenContract] = farmToHarvest
        log Harvest(tokenContract, farmToHarvest.marketType, yieldAmount)

@external
def withdraw():
    self.ownable(msg.sender)

    ifexBalance: uint256 = ERC20(self.ifexTokenContract).balanceOf(self)
    ERC20(self.ifexTokenContract).transfer(self.owner, ifexBalance)
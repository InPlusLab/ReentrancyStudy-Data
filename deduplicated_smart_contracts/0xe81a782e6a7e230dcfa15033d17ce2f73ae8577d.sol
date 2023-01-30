from vyper.interfaces import ERC721

implements: ERC721

interface pria_contract:
    def balanceOf(_to: address) -> uint256: view
    def totalSupply() -> uint256: view

interface ERC721Receiver:
    def onERC721Received(
            _operator: address,
            _from: address,
            _tokenId: uint256,
            _data: Bytes[1024]
        ) -> bytes32: view

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    tokenId: indexed(uint256)

event Approval:
    owner: indexed(address)
    approved: indexed(address)
    tokenId: indexed(uint256)

event ApprovalForAll:
    owner: indexed(address)
    operator: indexed(address)
    approved: bool

struct nft_token:
    name: String[64]
    thumbnail: String[100]
    model_url: String[100]
    Coef_1: uint256
    Coef_2: uint256
    Coef_3: uint256

tokenName: String[64]
tokenSymbol: String[32]
tokenUrl: String[100]
total_supply: uint256
earlyAdopters: public(HashMap[address, bool])
idToOwner: HashMap[uint256, address]
idToApprovals: HashMap[uint256, address]
arAsset: public(HashMap[uint256, nft_token])
ownerToNFTokenCount: HashMap[address, uint256]
ownerToOperators: HashMap[address, HashMap[address, bool]]
minter: address
supportedInterfaces: HashMap[bytes32, bool]
eav_title: String[64]
eav_thumbnail: String[100]
eav_model_url: String[100]
eav_coef1: uint256
eav_coef2: uint256
eav_coef3: uint256
deadline: uint256
eav_contract: address

ERC165_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000001ffc9a7
ERC721_INTERFACE_ID: constant(bytes32) = 0x0000000000000000000000000000000000000000000000000000000080ac58cd
ERC721_TOKEN_RECEIVER_INTERFACE_ID: constant(bytes32) = 0x00000000000000000000000000000000000000000000000000000000150b7a02
ERC721_METADATA_INTERFACE_ID: constant(bytes32) = 0x000000000000000000000000000000000000000000000000000000005b5e139f

@external
def __init__(_name: String[64], _symbol: String[32], _tokenURL: String[64]):
    self.tokenName = _name
    self.tokenSymbol = _symbol
    self.tokenUrl = _tokenURL
    self.supportedInterfaces[ERC165_INTERFACE_ID] = True
    self.supportedInterfaces[ERC721_INTERFACE_ID] = True
    self.supportedInterfaces[ERC721_TOKEN_RECEIVER_INTERFACE_ID] = True
    self.supportedInterfaces[ERC721_METADATA_INTERFACE_ID] = True
    self.minter = msg.sender
    self.total_supply = 0

@view
@external
def name() -> String[64]:
    return self.tokenName

@view
@external
def symbol() -> String[32]:
    return self.tokenSymbol

@view
@external
def totalSupply() -> uint256:
    return self.total_supply

@view
@external
def supportsInterface(_interfaceID: bytes32) -> bool:
    return self.supportedInterfaces[_interfaceID]

@view
@external
def tokenURL() -> String[100]:
    return self.tokenUrl

@view
@external
def balanceOf(_owner: address) -> uint256:
    assert _owner != ZERO_ADDRESS
    return self.ownerToNFTokenCount[_owner]

@view
@external
def ownerOf(_tokenId: uint256) -> address:
    owner: address = self.idToOwner[_tokenId]
    assert owner != ZERO_ADDRESS
    return owner

@view
@external
def NFT_AR_Name(_tokenId: uint256) -> String[100]:
    return self.arAsset[_tokenId].name

@view
@external
def NFT_AR_Thumbnail(_tokenId: uint256) -> String[100]:
    return self.arAsset[_tokenId].thumbnail

@view
@external
def NFT_AR_Contents(_tokenId: uint256) -> String[100]:
    return self.arAsset[_tokenId].model_url

@view
@external
def NFT_AR_Coef1(_tokenId: uint256) -> uint256:
    return self.arAsset[_tokenId].Coef_1

@view
@external
def NFT_AR_Coef2(_tokenId: uint256) -> uint256:
    return self.arAsset[_tokenId].Coef_2

@view
@external
def NFT_AR_Coef3(_tokenId: uint256) -> uint256:
    return self.arAsset[_tokenId].Coef_3

@view
@external
def getApproved(_tokenId: uint256) -> address:
    assert self.idToOwner[_tokenId] != ZERO_ADDRESS
    return self.idToApprovals[_tokenId]

@view
@external
def isApprovedForAll(_owner: address, _operator: address) -> bool:
    return (self.ownerToOperators[_owner])[_operator]

@view
@internal
def _isApprovedOrOwner(_spender: address, _tokenId: uint256) -> bool:
    owner: address = self.idToOwner[_tokenId]
    spenderIsOwner: bool = owner == _spender
    spenderIsApproved: bool = _spender == self.idToApprovals[_tokenId]
    spenderIsApprovedForAll: bool = (self.ownerToOperators[owner])[_spender]
    return (spenderIsOwner or spenderIsApproved) or spenderIsApprovedForAll

@internal
def _addTokenTo(_to: address, _tokenId: uint256):
    assert self.idToOwner[_tokenId] == ZERO_ADDRESS
    self.idToOwner[_tokenId] = _to
    self.ownerToNFTokenCount[_to] += 1

@internal
def _removeTokenFrom(_from: address, _tokenId: uint256):
    assert self.idToOwner[_tokenId] == _from
    self.idToOwner[_tokenId] = ZERO_ADDRESS
    self.ownerToNFTokenCount[_from] -= 1

@internal
def _clearApproval(_owner: address, _tokenId: uint256):
    assert self.idToOwner[_tokenId] == _owner
    if self.idToApprovals[_tokenId] != ZERO_ADDRESS:
        self.idToApprovals[_tokenId] = ZERO_ADDRESS

@internal
def _transferFrom(_from: address, _to: address, _tokenId: uint256, _sender: address):
    assert self._isApprovedOrOwner(_sender, _tokenId)
    assert _to != ZERO_ADDRESS
    self._clearApproval(_from, _tokenId)
    self._removeTokenFrom(_from, _tokenId)
    self._addTokenTo(_to, _tokenId)
    log Transfer(_from, _to, _tokenId)

@external
def transferFrom(_from: address, _to: address, _tokenId: uint256):
    self._transferFrom(_from, _to, _tokenId, msg.sender)

@external
def safeTransferFrom(_from: address, _to: address, _tokenId: uint256, _data: Bytes[1024]=b""):
    self._transferFrom(_from, _to, _tokenId, msg.sender)
    if _to.is_contract:
        returnValue: bytes32 = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data)
        assert returnValue == method_id("onERC721Received(address,address,uint256,bytes)", output_type=bytes32)

@external
def approve(_approved: address, _tokenId: uint256):
    owner: address = self.idToOwner[_tokenId]
    assert owner != ZERO_ADDRESS
    assert _approved != owner
    senderIsOwner: bool = self.idToOwner[_tokenId] == msg.sender
    senderIsApprovedForAll: bool = (self.ownerToOperators[owner])[msg.sender]
    assert (senderIsOwner or senderIsApprovedForAll)
    self.idToApprovals[_tokenId] = _approved
    log Approval(owner, _approved, _tokenId)

@external
def setApprovalForAll(_operator: address, _approved: bool):
    assert _operator != msg.sender
    self.ownerToOperators[msg.sender][_operator] = _approved
    log ApprovalForAll(msg.sender, _operator, _approved)

@external
def mint(_to: address, _name: String[64], _image: String[100], _url: String[100], _coef1: uint256, _coef2: uint256, _coef3: uint256) -> bool:
    assert msg.sender == self.minter
    assert _to != ZERO_ADDRESS
    self._addTokenTo(_to, self.total_supply)
    self.arAsset[self.total_supply].name = _name
    self.arAsset[self.total_supply].thumbnail = _image
    self.arAsset[self.total_supply].model_url = _url
    self.arAsset[self.total_supply].Coef_1 = _coef1
    self.arAsset[self.total_supply].Coef_2 = _coef2
    self.arAsset[self.total_supply].Coef_3 = _coef3
    log Transfer(ZERO_ADDRESS, _to, self.total_supply)
    self.total_supply += 1
    return True

@external
def setEarlyAdoptersNFT(_name: String[64], _thumbnail: String[100], _model_url: String[100], _coef1: uint256, _coef2: uint256, _coef3: uint256, _deadline: uint256) -> bool:
    assert msg.sender == self.minter
    assert msg.sender != ZERO_ADDRESS
    self.eav_title = _name
    self.eav_thumbnail = _thumbnail
    self.eav_model_url = _model_url
    self.eav_coef1 = _coef1
    self.eav_coef2 = _coef2
    self.eav_coef3 = _coef3
    self.deadline = _deadline
    return True

@external
def setContract(_contract: address) -> bool:
    assert msg.sender == self.minter
    assert msg.sender != ZERO_ADDRESS
    self.eav_contract = _contract
    return True

@external
def setTokenURL(_url: String[100]) -> bool:
    assert msg.sender == self.minter
    assert msg.sender != ZERO_ADDRESS
    self.tokenUrl = _url
    return True

@external
def CLAIMearlyAdoptersNFT() -> bool:
    assert self.earlyAdopters[msg.sender] == True
    assert msg.sender != ZERO_ADDRESS
    assert self.deadline > block.timestamp
    self._addTokenTo(msg.sender, self.total_supply)
    r: uint256 = pria_contract(self.eav_contract).balanceOf(msg.sender)
    totalsupply: uint256 = pria_contract(self.eav_contract).totalSupply()
    pct: uint256 = (r*10**18)/totalsupply
    self.arAsset[self.total_supply].name = self.eav_title
    self.arAsset[self.total_supply].thumbnail = self.eav_thumbnail
    self.arAsset[self.total_supply].model_url = self.eav_model_url
    self.arAsset[self.total_supply].Coef_1 = pct
    self.arAsset[self.total_supply].Coef_2 = self.eav_coef2
    self.arAsset[self.total_supply].Coef_3 = self.eav_coef3
    log Transfer(ZERO_ADDRESS, msg.sender, self.total_supply)
    self.total_supply += 1
    self.earlyAdopters[msg.sender] = False
    return True

@external
def burn(_tokenId: uint256):
    assert self._isApprovedOrOwner(msg.sender, _tokenId)
    owner: address = self.idToOwner[_tokenId]
    assert owner != ZERO_ADDRESS
    self._clearApproval(owner, _tokenId)
    self._removeTokenFrom(owner, _tokenId)
    self.arAsset[_tokenId].name = ""
    self.arAsset[_tokenId].thumbnail = ""
    self.arAsset[_tokenId].model_url = ""
    self.arAsset[_tokenId].Coef_1 = 0
    self.arAsset[_tokenId].Coef_2 = 0
    self.arAsset[_tokenId].Coef_3 = 0
    log Transfer(owner, ZERO_ADDRESS, _tokenId)

@external
def setEligible_Single(_eligibleAddy: address) -> bool:
    assert msg.sender == self.minter
    self.earlyAdopters[_eligibleAddy] = True
    return True

@external
def remEligible_Single(_eligibleAddy: address) -> bool:
    assert msg.sender == self.minter
    self.earlyAdopters[_eligibleAddy] = False
    return True

@external
def remEligible_Bulk(_eligibleList: address[100]) -> bool:
    assert msg.sender == self.minter
    for addy in range (0, 100):
        if _eligibleList[addy] != ZERO_ADDRESS:
            self.earlyAdopters[_eligibleList[addy]] = False
        else:
            break
    return True

@external
def setEligible_Bulk(_eligibleList: address[100]) -> bool:
    assert msg.sender == self.minter
    for addy in range (0, 100):
        if _eligibleList[addy] != ZERO_ADDRESS:
            self.earlyAdopters[_eligibleList[addy]] = True
        else:
            break
    return True

@external
def remEligible_Bulk_300(_eligibleList: address[300]) -> bool:
    assert msg.sender == self.minter
    for addy in range (0, 300):
        if _eligibleList[addy] != ZERO_ADDRESS:
            self.earlyAdopters[_eligibleList[addy]] = False
        else:
            break
    return True

@external
def setEligible_Bulk_300(_eligibleList: address[300]) -> bool:
    assert msg.sender == self.minter
    for addy in range (0, 300):
        if _eligibleList[addy] != ZERO_ADDRESS:
            self.earlyAdopters[_eligibleList[addy]] = True
        else:
            break
    return True

@external
def sweep():
    assert msg.sender == self.minter
    assert msg.sender != ZERO_ADDRESS
    selfdestruct(msg.sender)
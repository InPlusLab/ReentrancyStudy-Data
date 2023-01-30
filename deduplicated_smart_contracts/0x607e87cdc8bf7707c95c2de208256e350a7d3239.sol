pragma solidity ^0.4.21;

contract ERC721 {
    // Required methods
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external view returns (bool);
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address previousOwner, address newOwner);

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract StorageBase is Ownable {

    function withdrawBalance() external onlyOwner returns (bool) {
        // The owner has a method to withdraw balance from multiple contracts together,
        // use send here to make sure even if one withdrawBalance fails the others will still work
        bool res = msg.sender.send(address(this).balance);
        return res;
    }
}

contract ClockAuctionStorage is StorageBase {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address seller;
        // Price (in wei) at beginning of auction
        uint128 startingPrice;
        // Price (in wei) at end of auction
        uint128 endingPrice;
        // Duration (in seconds) of auction
        uint64 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;
    }

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) tokenIdToAuction;

    function addAuction(
        uint256 _tokenId,
        address _seller,
        uint128 _startingPrice,
        uint128 _endingPrice,
        uint64 _duration,
        uint64 _startedAt
    )
        external
        onlyOwner
    {
        tokenIdToAuction[_tokenId] = Auction(
            _seller,
            _startingPrice,
            _endingPrice,
            _duration,
            _startedAt
        );
    }

    function removeAuction(uint256 _tokenId) public onlyOwner {
        delete tokenIdToAuction[_tokenId];
    }

    function getAuction(uint256 _tokenId)
        external
        view
        returns (
            address seller,
            uint128 startingPrice,
            uint128 endingPrice,
            uint64 duration,
            uint64 startedAt
        )
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt
        );
    }

    function isOnAuction(uint256 _tokenId) external view returns (bool) {
        return (tokenIdToAuction[_tokenId].startedAt > 0);
    }

    function getSeller(uint256 _tokenId) external view returns (address) {
        return tokenIdToAuction[_tokenId].seller;
    }

    function transfer(ERC721 _nonFungibleContract, address _receiver, uint256 _tokenId) external onlyOwner {
        // it will throw if transfer fails
        _nonFungibleContract.transfer(_receiver, _tokenId);
    }
}

contract SaleClockAuctionStorage is ClockAuctionStorage {
    bool public isSaleClockAuctionStorage = true;

    // total accumulate sold count
    uint256 public totalSoldCount;

    // last 3 sale price
    uint256[3] public lastSoldPrices;

    // current on sale auction count from system
    uint256 public systemOnSaleCount;

    // map of on sale token ids from system
    mapping (uint256 => bool) systemOnSaleTokens;

    function removeAuction(uint256 _tokenId) public onlyOwner {
        // first remove auction from state variable
        super.removeAuction(_tokenId);

        // update system on sale record
        if (systemOnSaleTokens[_tokenId]) {
            delete systemOnSaleTokens[_tokenId];
            
            if (systemOnSaleCount > 0) {
                systemOnSaleCount--;
            }
        }
    }

    function recordSystemOnSaleToken(uint256 _tokenId) external onlyOwner {
        if (!systemOnSaleTokens[_tokenId]) {
            systemOnSaleTokens[_tokenId] = true;
            systemOnSaleCount++;
        }
    }

    function recordSoldPrice(uint256 _price) external onlyOwner {
        lastSoldPrices[totalSoldCount % 3] = _price;
        totalSoldCount++;
    }

    function averageSoldPrice() external view returns (uint256) {
        if (totalSoldCount == 0) return 0;
        
        uint256 sum = 0;
        uint256 len = (totalSoldCount < 3 ? totalSoldCount : 3);
        for (uint256 i = 0; i < len; i++) {
            sum += lastSoldPrices[i];
        }
        return sum / len;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

contract HasNoContracts is Pausable {

    function reclaimContract(address _contractAddr) external onlyOwner whenPaused {
        Ownable contractInst = Ownable(_contractAddr);
        contractInst.transferOwnership(owner);
    }
}

contract LogicBase is HasNoContracts {

    /// The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_NFC = bytes4(0x9f40b779);

    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;

    // Reference to storage contract
    StorageBase public storageContract;

    function LogicBase(address _nftAddress, address _storageAddress) public {
        // paused by default
        paused = true;

        setNFTAddress(_nftAddress);

        require(_storageAddress != address(0));
        storageContract = StorageBase(_storageAddress);
    }

    // Very dangerous action, only when new contract has been proved working
    // Requires storageContract already transferOwnership to the new contract
    // This method is only used to transfer the balance to owner
    function destroy() external onlyOwner whenPaused {
        address storageOwner = storageContract.owner();
        // owner of storageContract must not be the current contract otherwise the storageContract will forever not accessible
        require(storageOwner != address(this));
        // Transfers the current balance to the owner and terminates the contract
        selfdestruct(owner);
    }

    // Very dangerous action, only when new contract has been proved working
    // Requires storageContract already transferOwnership to the new contract
    // This method is only used to transfer the balance to the new contract
    function destroyAndSendToStorageOwner() external onlyOwner whenPaused {
        address storageOwner = storageContract.owner();
        // owner of storageContract must not be the current contract otherwise the storageContract will forever not accessible
        require(storageOwner != address(this));
        // Transfers the current balance to the new owner of the storage contract and terminates the contract
        selfdestruct(storageOwner);
    }

    // override to make sure everything is initialized before the unpause
    function unpause() public onlyOwner whenPaused {
        // can not unpause when the logic contract is not initialzed
        require(nonFungibleContract != address(0));
        require(storageContract != address(0));
        // can not unpause when ownership of storage contract is not the current contract
        require(storageContract.owner() == address(this));

        super.unpause();
    }

    function setNFTAddress(address _nftAddress) public onlyOwner {
        require(_nftAddress != address(0));
        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_NFC));
        nonFungibleContract = candidateContract;
    }

    // Withdraw balance to the Core Contract
    function withdrawBalance() external returns (bool) {
        address nftAddress = address(nonFungibleContract);
        // either Owner or Core Contract can trigger the withdraw
        require(msg.sender == owner || msg.sender == nftAddress);
        // The owner has a method to withdraw balance from multiple contracts together,
        // use send here to make sure even if one withdrawBalance fails the others will still work
        bool res = nftAddress.send(address(this).balance);
        return res;
    }

    function withdrawBalanceFromStorageContract() external returns (bool) {
        address nftAddress = address(nonFungibleContract);
        // either Owner or Core Contract can trigger the withdraw
        require(msg.sender == owner || msg.sender == nftAddress);
        // The owner has a method to withdraw balance from multiple contracts together,
        // use send here to make sure even if one withdrawBalance fails the others will still work
        bool res = storageContract.withdrawBalance();
        return res;
    }
}

contract ClockAuction is LogicBase {
    
    // Reference to contract tracking auction state variables
    ClockAuctionStorage public clockAuctionStorage;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;

    // Minimum cut value on each auction (in WEI)
    uint256 public minCutValue;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner, address seller, uint256 sellerProceeds);
    event AuctionCancelled(uint256 tokenId);

    function ClockAuction(address _nftAddress, address _storageAddress, uint256 _cut, uint256 _minCutValue) 
        LogicBase(_nftAddress, _storageAddress) public
    {
        setOwnerCut(_cut);
        setMinCutValue(_minCutValue);

        clockAuctionStorage = ClockAuctionStorage(_storageAddress);
    }

    function setOwnerCut(uint256 _cut) public onlyOwner {
        require(_cut <= 10000);
        ownerCut = _cut;
    }

    function setMinCutValue(uint256 _minCutValue) public onlyOwner {
        minCutValue = _minCutValue;
    }

    function getMinPrice() public view returns (uint256) {
        // return ownerCut > 0 ? (minCutValue / ownerCut * 10000) : 0;
        // use minCutValue directly, when the price == minCutValue seller will get no profit
        return minCutValue;
    }

    // Only auction from none system user need to verify the price
    // System auction can set any price
    function isValidPrice(uint256 _startingPrice, uint256 _endingPrice) public view returns (bool) {
        return (_startingPrice < _endingPrice ? _startingPrice : _endingPrice) >= getMinPrice();
    }

    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        public
        whenNotPaused
    {
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        
        // assigning ownership to this clockAuctionStorage when in auction
        // it will throw if transfer fails
        nonFungibleContract.transferFrom(_seller, address(clockAuctionStorage), _tokenId);

        // Require that all auctions have a duration of at least one minute.
        require(_duration >= 1 minutes);

        clockAuctionStorage.addAuction(
            _tokenId,
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );

        emit AuctionCreated(_tokenId, _startingPrice, _endingPrice, _duration);
    }

    function cancelAuction(uint256 _tokenId) external {
        require(clockAuctionStorage.isOnAuction(_tokenId));
        address seller = clockAuctionStorage.getSeller(_tokenId);
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    function cancelAuctionWhenPaused(uint256 _tokenId) external whenPaused onlyOwner {
        require(clockAuctionStorage.isOnAuction(_tokenId));
        address seller = clockAuctionStorage.getSeller(_tokenId);
        _cancelAuction(_tokenId, seller);
    }

    function getAuction(uint256 _tokenId)
        public
        view
        returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        require(clockAuctionStorage.isOnAuction(_tokenId));
        return clockAuctionStorage.getAuction(_tokenId);
    }

    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        require(clockAuctionStorage.isOnAuction(_tokenId));
        return _currentPrice(_tokenId);
    }

    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        clockAuctionStorage.removeAuction(_tokenId);
        clockAuctionStorage.transfer(nonFungibleContract, _seller, _tokenId);
        emit AuctionCancelled(_tokenId);
    }

    function _bid(uint256 _tokenId, uint256 _bidAmount, address bidder) internal returns (uint256) {

        require(clockAuctionStorage.isOnAuction(_tokenId));

        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(_tokenId);
        require(_bidAmount >= price);

        address seller = clockAuctionStorage.getSeller(_tokenId);
        uint256 sellerProceeds = 0;

        // Remove the auction before sending the fees to the sender so we can't have a reentrancy attack
        clockAuctionStorage.removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut, so this subtraction can't go negative
            uint256 auctioneerCut = _computeCut(price);
            sellerProceeds = price - auctioneerCut;

            // transfer the sellerProceeds
            seller.transfer(sellerProceeds);
        }

        // Calculate any excess funds included with the bid
        // transfer it back to bidder.
        // this cannot underflow.
        uint256 bidExcess = _bidAmount - price;
        bidder.transfer(bidExcess);

        emit AuctionSuccessful(_tokenId, price, bidder, seller, sellerProceeds);

        return price;
    }

    function _currentPrice(uint256 _tokenId) internal view returns (uint256) {

        uint256 secondsPassed = 0;

        address seller;
        uint128 startingPrice;
        uint128 endingPrice;
        uint64 duration;
        uint64 startedAt;
        (seller, startingPrice, endingPrice, duration, startedAt) = clockAuctionStorage.getAuction(_tokenId);

        if (now > startedAt) {
            secondsPassed = now - startedAt;
        }

        return _computeCurrentPrice(
            startingPrice,
            endingPrice,
            duration,
            secondsPassed
        );
    }

    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        if (_secondsPassed >= _duration) {
            return _endingPrice;
        } else {
            // this delta can be negative.
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

            // This multiplication can't overflow, _secondsPassed will easily fit within
            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);

            // this result will always end up positive.
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    function _computeCut(uint256 _price) internal view returns (uint256) {
        uint256 cutValue = _price * ownerCut / 10000;
        if (_price < minCutValue) return cutValue;
        if (cutValue > minCutValue) return cutValue;
        return minCutValue;
    }
}

contract SaleClockAuction is ClockAuction {

    bool public isSaleClockAuction = true;

    address public systemSaleAddress;
    uint256 public systemStartingPriceMin = 20 finney;
    uint256 public systemEndingPrice = 0;
    uint256 public systemAuctionDuration = 1 days;

    function SaleClockAuction(address _nftAddr, address _storageAddress, address _systemSaleAddress, uint256 _cut, uint256 _minCutValue) 
        ClockAuction(_nftAddr, _storageAddress, _cut, _minCutValue) public
    {
        require(SaleClockAuctionStorage(_storageAddress).isSaleClockAuctionStorage());
        
        setSystemSaleAddress(_systemSaleAddress);
    }
  
    function bid(uint256 _tokenId) external payable {
        uint256 price = _bid(_tokenId, msg.value, msg.sender);
        
        clockAuctionStorage.transfer(nonFungibleContract, msg.sender, _tokenId);
        
        SaleClockAuctionStorage(clockAuctionStorage).recordSoldPrice(price);
    }

    function createSystemAuction(uint256 _tokenId) external {
        require(msg.sender == address(nonFungibleContract));

        createAuction(
            _tokenId,
            computeNextSystemSalePrice(),
            systemEndingPrice,
            systemAuctionDuration,
            systemSaleAddress
        );

        SaleClockAuctionStorage(clockAuctionStorage).recordSystemOnSaleToken(_tokenId);
    }

    function setSystemSaleAddress(address _systemSaleAddress) public onlyOwner {
        require(_systemSaleAddress != address(0));
        systemSaleAddress = _systemSaleAddress;
    }

    function setSystemStartingPriceMin(uint256 _startingPrice) external onlyOwner {
        require(_startingPrice == uint256(uint128(_startingPrice)));
        systemStartingPriceMin = _startingPrice;
    }

    function setSystemEndingPrice(uint256 _endingPrice) external onlyOwner {
        require(_endingPrice == uint256(uint128(_endingPrice)));
        systemEndingPrice = _endingPrice;
    }

    function setSystemAuctionDuration(uint256 _duration) external onlyOwner {
        require(_duration == uint256(uint64(_duration)));
        systemAuctionDuration = _duration;
    }

    function totalSoldCount() external view returns (uint256) {
        return SaleClockAuctionStorage(clockAuctionStorage).totalSoldCount();
    }

    function systemOnSaleCount() external view returns (uint256) {
        return SaleClockAuctionStorage(clockAuctionStorage).systemOnSaleCount();
    }

    function averageSoldPrice() external view returns (uint256) {
        return SaleClockAuctionStorage(clockAuctionStorage).averageSoldPrice();
    }

    function computeNextSystemSalePrice() public view returns (uint256) {
        uint256 avePrice = SaleClockAuctionStorage(clockAuctionStorage).averageSoldPrice();

        require(avePrice == uint256(uint128(avePrice)));

        uint256 nextPrice = avePrice + (avePrice / 2);

        if (nextPrice < systemStartingPriceMin) {
            nextPrice = systemStartingPriceMin;
        }

        return nextPrice;
    }
}
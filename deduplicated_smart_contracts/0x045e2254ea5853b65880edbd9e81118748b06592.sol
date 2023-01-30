// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @title IERC1155 Non-Fungible Token Creator basic interface
 */
interface IERC1155TokenCreator {
    /**
     * @dev Gets the creator of the token
     * @param _tokenId uint256 ID of the token
     * @return address of the creator
     */
    function tokenCreator(uint256 _tokenId)
    external
    view
    returns (address payable);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @title IMarketplaceSettings Settings governing a marketplace.
 */
interface IMarketplaceSettings {
    /////////////////////////////////////////////////////////////////////////
    // Marketplace Min and Max Values
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get the max value to be used with the marketplace.
     * @return uint256 wei value.
     */
    function getMarketplaceMaxValue() external view returns (uint256);

    /**
     * @dev Get the max value to be used with the marketplace.
     * @return uint256 wei value.
     */
    function getMarketplaceMinValue() external view returns (uint256);

    /////////////////////////////////////////////////////////////////////////
    // Marketplace Fee
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get the marketplace fee percentage.
     * @return uint8 wei fee.
     */
    function getMarketplaceFeePercentage() external view returns (uint8);

    /**
     * @dev Utility function for calculating the marketplace fee for given amount of wei.
     * @param _amount uint256 wei amount.
     * @return uint256 wei fee.
     */
    function calculateMarketplaceFee(uint256 _amount)
    external
    view
    returns (uint256);

    /////////////////////////////////////////////////////////////////////////
    // Primary Sale Fee
    /////////////////////////////////////////////////////////////////////////
    /**
     * @dev Get the primary sale fee percentage for a specific ERC1155 contract.
     * @return uint8 wei primary sale fee.
     */
    function getERC1155ContractPrimarySaleFeePercentage()
    external
    view
    returns (uint8);

    /**
     * @dev Utility function for calculating the primary sale fee for given amount of wei
     * @param _amount uint256 wei amount.
     * @return uint256 wei fee.
     */
    function calculatePrimarySaleFee(uint256 _amount)
    external
    view
    returns (uint256);

    /**
     * @dev Check whether the ERC1155 token has sold at least once.
     * @param _tokenId uint256 token ID.
     * @return bool of whether the token has sold.
     */
    function hasTokenSold(uint256 _tokenId)
    external
    view
    returns (bool);

    /**
     * @dev Mark a token as sold.

     * Requirements:
     *
     * - `_contractAddress` cannot be the zero address.

     * @param _tokenId uint256 token ID.
     * @param _hasSold bool of whether the token should be marked sold or not.
     */
    function markERC1155Token(
        uint256 _tokenId,
        bool _hasSold
    ) external;
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;


/**
 * @dev Interface for interacting with the Nafter contract that holds Nafter beta tokens.
 */
interface INafter {

    /**
     * @dev Gets the creator of the token
     * @param _tokenId uint256 ID of the token
     * @return address of the creator
     */
    function creatorOfToken(uint256 _tokenId)
    external
    view
    returns (address payable);

    /**
     * @dev Gets the Service Fee
     * @param _tokenId uint256 ID of the token
     * @return address of the creator
     */
    function getServiceFee(uint256 _tokenId)
    external
    view
    returns (uint8);

    /**
     * @dev Gets the price type
     * @param _tokenId uint256 ID of the token
     * @param _owner address of the token owner
     * @return get the price type
     */
    function getPriceType(uint256 _tokenId, address _owner)
    external
    view
    returns (uint8);

    /**
     * @dev update price only from auction.
     * @param _price price of the token
     * @param _tokenId uint256 id of the token.
     * @param _owner address of the token owner
     */
    function setPrice(uint256 _price, uint256 _tokenId, address _owner) external;

    /**
     * @dev update bids only from auction.
     * @param _bid bid Amount
     * @param _bidder bidder address
     * @param _tokenId uint256 id of the token.
     * @param _owner address of the token owner
     */
    function setBid(uint256 _bid, address _bidder, uint256 _tokenId, address _owner) external;

    /**
     * @dev remove token from sale
     * @param _tokenId uint256 id of the token.
     * @param _owner owner of the token
     */
    function removeFromSale(uint256 _tokenId, address _owner) external;

    /**
     * @dev get tokenIds length
     */
    function getTokenIdsLength() external view returns (uint256);

    /**
     * @dev get token Id
     * @param _index uint256 index
     */
    function getTokenId(uint256 _index) external view returns (uint256);

    /**
     * @dev Gets the owners
     * @param _tokenId uint256 ID of the token
     */
    function getOwners(uint256 _tokenId)
    external
    view
    returns (address[] memory owners);

    /**
     * @dev Gets the is for sale
     * @param _tokenId uint256 ID of the token
     * @param _owner address of the token owner
     */
    function getIsForSale(uint256 _tokenId, address _owner) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface INafterMarketAuction {
    /**
     * @dev Set the token for sale. The owner of the token must be the sender and have the marketplace approved.
     * @param _tokenId uint256 ID of the token
     * @param _amount uint256 wei value that the item is for sale
     */
    function setSalePrice(
        uint256 _tokenId,
        uint256 _amount,
        address _owner
    ) external;

    /**
     * @dev set
     * @param _bidAmount uint256 value in wei to bid.
     * @param _startTime end time of bid
     * @param _endTime end time of bid
     * @param _owner address of the token owner
     * @param _tokenId uint256 ID of the token
     */
    function setInitialBidPriceWithRange(
        uint256 _bidAmount,
        uint256 _startTime,
        uint256 _endTime,
        address _owner,
        uint256 _tokenId
    ) external;

    /**
     * @dev has active bid
     * @param _tokenId uint256 ID of the token
     * @param _owner address of the token owner
     */
    function hasTokenActiveBid(uint256 _tokenId, address _owner) external view returns (bool);

}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./IERC1155TokenCreator.sol";

/**
 * @title IERC1155CreatorRoyalty Token level royalty interface.
 */
interface INafterRoyaltyRegistry is IERC1155TokenCreator {
    /**
     * @dev Get the royalty fee percentage for a specific ERC1155 contract.
     * @param _tokenId uint256 token ID.
     * @return uint8 wei royalty fee.
     */
    function getTokenRoyaltyPercentage(
        uint256 _tokenId
    ) external view returns (uint8);

    /**
     * @dev Utililty function to calculate the royalty fee for a token.
     * @param _tokenId uint256 token ID.
     * @param _amount uint256 wei amount.
     * @return uint256 wei fee.
     */
    function calculateRoyaltyFee(
        uint256 _tokenId,
        uint256 _amount
    ) external view returns (uint256);

    /**
     * @dev Sets the royalty percentage set for an Nafter token
     * Requirements:

     * - `_percentage` must be <= 100.
     * - only the owner of this contract or the creator can call this method.
     * @param _tokenId uint256 token ID.
     * @param _percentage uint8 wei royalty fee.
     */
    function setPercentageForTokenRoyalty(
        uint256 _tokenId,
        uint8 _percentage
    ) external returns (uint8);
}

// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

/**
 * @title IERC721 Non-Fungible Token Creator basic interface
 */
interface INafterTokenCreatorRegistry {
    /**
     * @dev Gets the creator of the token
     * @param _tokenId uint256 ID of the token
     * @return address of the creator
     */
    function tokenCreator(uint256 _tokenId)
    external
    view
    returns (address payable);

    /**
     * @dev Sets the creator of the token
     * @param _tokenId uint256 ID of the token
     * @param _creator address of the creator for the token
     */
    function setTokenCreator(
        uint256 _tokenId,
        address payable _creator
    ) external;
}

// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "./INafter.sol";
import "./INafterMarketAuction.sol";
import "./IMarketplaceSettings.sol";
import "./INafterRoyaltyRegistry.sol";
import "./INafterTokenCreatorRegistry.sol";
/**
 * Nafter core contract.
*/

contract Nafter is ERC1155, Ownable, INafter {
    // Library to overcome overflow
    using SafeMath for uint256;
    struct TokenInfo {
        uint256 tokenId;
        address creator;
        uint256 tokenAmount;
        address[] owners;
        uint8 serviceFee;
        uint256 creationTime;
    }

    struct TokenOwnerInfo {
        bool isForSale;
        uint8 priceType; // 0 for fixed, 1 for Auction dates range, 2 for Auction Infinity
        uint256[] prices;
        uint256[] bids;
        address[] bidders;
    }

    // market auction to set the price
    INafterMarketAuction marketAuction;
    IMarketplaceSettings marketplaceSettings;
    INafterRoyaltyRegistry royaltyRegistry;
    INafterTokenCreatorRegistry tokenCreatorRigistry;

    // mapping of token info
    mapping(uint256 => TokenInfo) public tokenInfo;
    mapping(uint256 => mapping(address => TokenOwnerInfo)) public tokenOwnerInfo;

    mapping(uint256 => bool) public tokenIdsAvailable;

    uint256[] public tokenIds;
    uint256 public maxId;

    // Event indicating metadata was updated.
    event AddNewToken(address user, uint256 tokenId);
    event DeleteTokens(address user, uint256 tokenId, uint256 amount);
    event SetURI(string uri);

    constructor(
        string memory _uri
    ) public
    ERC1155(_uri)
    {

    }

    /**
     * @dev Gets the creator of the token
     * @param _tokenId uint256 ID of the token
     * @return address of the creator
     */
    function creatorOfToken(uint256 _tokenId)
    external
    view override
    returns (address payable) {
        return payable(tokenInfo[_tokenId].creator);
    }

    /**
     * @dev Gets the Service Fee
     * @param _tokenId uint256 ID of the token
     * @return get the service fee
     */
    function getServiceFee(uint256 _tokenId)
    external
    view override
    returns (uint8){
        return tokenInfo[_tokenId].serviceFee;
    }

    /**
     * @dev Gets the price type
     * @param _tokenId uint256 ID of the token
     * @param _owner address of the token owner
     * @return get the price type
     */
    function getPriceType(uint256 _tokenId, address _owner)
    external
    view override
    returns (uint8){
        return tokenOwnerInfo[_tokenId][_owner].priceType;
    }

    /**
     * @dev Gets the token amount
     * @param _tokenId uint256 ID of the token
     */
    function getTokenAmount(uint256 _tokenId)
    external
    view
    returns (uint256){
        return tokenInfo[_tokenId].tokenAmount;
    }

    /**
     * @dev Gets the is for sale
     * @param _tokenId uint256 ID of the token
     * @param _owner address of the token owner
     */
    function getIsForSale(uint256 _tokenId, address _owner)
    external
    override
    view
    returns (bool){
        return tokenOwnerInfo[_tokenId][_owner].isForSale;
    }

    /**
     * @dev Gets the owners
     * @param _tokenId uint256 ID of the token
     */
    function getOwners(uint256 _tokenId)
    external
    override
    view
    returns (address[] memory owners){
        return tokenInfo[_tokenId].owners;
    }

    /**
     * @dev Gets the prices
     * @param _tokenId uint256 ID of the token
     * @param _owner address of the token owner
     */
    function getPrices(uint256 _tokenId, address _owner)
    external
    view
    returns (uint256[] memory prices){
        return tokenOwnerInfo[_tokenId][_owner].prices;
    }

    /**
     * @dev Gets the bids
     * @param _tokenId uint256 ID of the token
     * @param _owner address of the token owner
     */
    function getBids(uint256 _tokenId, address _owner)
    external
    view
    returns (uint256[] memory bids){
        return tokenOwnerInfo[_tokenId][_owner].bids;
    }

    /**
     * @dev Gets the bidders
     * @param _tokenId uint256 ID of the token
     * @param _owner address of the token owner
     */
    function getBidders(uint256 _tokenId, address _owner)
    external
    view
    returns (address[] memory bidders){
        return tokenOwnerInfo[_tokenId][_owner].bidders;
    }

    /**
     * @dev Gets the creation time
     * @param _tokenId uint256 ID of the token
     */
    function getCreationTime(uint256 _tokenId)
    external
    view
    returns (uint256){
        return tokenInfo[_tokenId].creationTime;
    }

    /**
     * @dev get tokenIds length
     */
    function getTokenIdsLength() external override view returns (uint256){
        return tokenIds.length;
    }

    /**
     * @dev get token Id
     * @param _index uint256 index
     */

    function getTokenId(uint256 _index) external override view returns (uint256){
        return tokenIds[_index];
    }
    /**
     * @dev get owner tokens
     * @param _owner address of owner.
     */

    function getOwnerTokens(address _owner) public view returns (TokenInfo[] memory tokens, TokenOwnerInfo[] memory ownerInfo) {

        uint totalValues;
        //calculate totalValues
        for (uint i = 0; i < tokenIds.length; i++) {
            TokenInfo memory info = tokenInfo[tokenIds[i]];
            if (info.owners[info.owners.length - 1] == _owner) {
                totalValues++;
            }
        }

        TokenInfo[] memory values = new TokenInfo[](totalValues);
        TokenOwnerInfo[] memory valuesOwner = new TokenOwnerInfo[](totalValues);
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            TokenInfo memory info = tokenInfo[tokenId];
            if (info.owners[info.owners.length - 1] == _owner) {
                values[i] = info;
                valuesOwner[i] = tokenOwnerInfo[tokenId][_owner];
            }
        }

        return (values, valuesOwner);
    }

    /**
     * @dev get token paging
     * @param _offset offset of the records.
     * @param _limit limits of the records.
     */
    function getTokensPaging(uint _offset, uint _limit) public view returns (TokenInfo[] memory tokens, uint nextOffset, uint total) {
        uint256 tokenInfoLength = tokenIds.length;
        if (_limit == 0) {
            _limit = 1;
        }

        if (_limit > tokenInfoLength - _offset) {
            _limit = tokenInfoLength - _offset;
        }

        TokenInfo[] memory values = new TokenInfo[] (_limit);
        for (uint i = 0; i < _limit; i++) {
            uint256 tokenId = tokenIds[_offset + i];
            values[i] = tokenInfo[tokenId];
        }

        return (values, _offset + _limit, tokenInfoLength);
    }

    /**
     * @dev Checks that the token was owned by the sender.
     * @param _tokenId uint256 ID of the token.
     */
    modifier onlyTokenOwner(uint256 _tokenId) {
        uint256 balance = balanceOf(msg.sender, _tokenId);
        require(balance > 0, "must be the owner of the token");
        _;
    }

    /**
     * @dev Checks that the token was created by the sender.
     * @param _tokenId uint256 ID of the token.
     */
    modifier onlyTokenCreator(uint256 _tokenId) {
        address creator = tokenInfo[_tokenId].creator;
        require(creator == msg.sender, "must be the creator of the token");
        _;
    }

    /**
     * @dev restore data from old contract, only call by owner
     * @param _oldAddress address of old contract.
     * @param _startIndex start index of array
     * @param _endIndex end index of array
     */
    function restore(address _oldAddress, uint256 _startIndex, uint256 _endIndex) external onlyOwner {
        Nafter oldContract = Nafter(_oldAddress);
        uint256 length = oldContract.getTokenIdsLength();
        require(_startIndex < length, "wrong start index");
        require(_endIndex <= length, "wrong end index");

        for (uint i = _startIndex; i < _endIndex; i++) {
            uint256 tokenId = oldContract.getTokenId(i);
            tokenIds.push(tokenId);
            //create seperate functions otherwise it will give stack too deep error
            tokenInfo[tokenId] = TokenInfo(
                tokenId,
                oldContract.creatorOfToken(tokenId),
                oldContract.getTokenAmount(tokenId),
                oldContract.getOwners(tokenId),
                oldContract.getServiceFee(tokenId),
                oldContract.getCreationTime(tokenId)
            );

            address[] memory owners = tokenInfo[tokenId].owners;
            for (uint j = 0; j < owners.length; j++) {
                address owner = owners[j];
                tokenOwnerInfo[tokenId][owner] = TokenOwnerInfo(
                    oldContract.getIsForSale(tokenId, owner),
                    oldContract.getPriceType(tokenId, owner),
                    oldContract.getPrices(tokenId, owner),
                    oldContract.getBids(tokenId, owner),
                    oldContract.getBidders(tokenId, owner)
                );

                uint256 ownerBalance = oldContract.balanceOf(owner, tokenId);
                if (ownerBalance > 0) {
                    _mint(owner, tokenId, ownerBalance, '');
                }
            }
            tokenIdsAvailable[tokenId] = true;
        }
        maxId = oldContract.maxId();
    }

    /**
     * @dev update or mint token Amount only from token creator.
     * @param _tokenAmount token Amount
     * @param _tokenId uint256 id of the token.
     */
    function setTokenAmount(uint256 _tokenAmount, uint256 _tokenId) external onlyTokenCreator(_tokenId) {
        tokenInfo[_tokenId].tokenAmount = tokenInfo[_tokenId].tokenAmount + _tokenAmount;
        _mint(msg.sender, _tokenId, _tokenAmount, '');
    }

    /**
     * @dev update is for sale only from token Owner.
     * @param _isForSale is For Sale
     * @param _tokenId uint256 id of the token.
     */
    function setIsForSale(bool _isForSale, uint256 _tokenId) public onlyTokenOwner(_tokenId) {
        tokenOwnerInfo[_tokenId][msg.sender].isForSale = _isForSale;
    }

    /**
     * @dev update is for sale only from token Owner.
     * @param _priceType set the price type
     * @param _price price of the token
     * @param _startTime start time of bid, pass 0 of _priceType is not 1
     * @param _endTime end time of bid, pass 0 of _priceType is not 1
     * @param _tokenId uint256 id of the token.
     * @param _owner owner of the token
     */
    function putOnSale(uint8 _priceType, uint256 _price, uint256 _startTime, uint256 _endTime, uint256 _tokenId, address _owner) public onlyTokenOwner(_tokenId) {
        if (_priceType == 0) {
            marketAuction.setSalePrice(_tokenId, _price, _owner);
        }
        if (_priceType == 1 || _priceType == 2) {
            marketAuction.setInitialBidPriceWithRange(_price, _startTime, _endTime, _owner, _tokenId);
        }
        tokenOwnerInfo[_tokenId][_owner].isForSale = true;
        tokenOwnerInfo[_tokenId][_owner].priceType = _priceType;
    }

    /**
     * @dev remove token from sale
     * @param _tokenId uint256 id of the token.
     * @param _owner owner of the token
     */
    function removeFromSale(uint256 _tokenId, address _owner) external override {
        uint256 balance = balanceOf(msg.sender, _tokenId);
        require(balance > 0 || msg.sender == address(marketAuction), "must be the owner of the token or sender is market auction");

        tokenOwnerInfo[_tokenId][_owner].isForSale = false;
    }

    /**
     * @dev update price type from token Owner.
     * @param _priceType price type
     * @param _tokenId uint256 id of the token.
     */
    function setPriceType(uint8 _priceType, uint256 _tokenId) external onlyTokenOwner(_tokenId) {
        tokenOwnerInfo[_tokenId][msg.sender].priceType = _priceType;
    }

    /**
     * @dev set marketAuction address to set the sale price
     * @param _marketAuction address of market auction.
     * @param _marketplaceSettings address of market auction.
     */
    function setMarketAddresses(address _marketAuction, address _marketplaceSettings, address _tokenCreatorRigistry, address _royaltyRegistry) external onlyOwner {
        marketAuction = INafterMarketAuction(_marketAuction);
        marketplaceSettings = IMarketplaceSettings(_marketplaceSettings);
        tokenCreatorRigistry = INafterTokenCreatorRegistry(_tokenCreatorRigistry);
        royaltyRegistry = INafterRoyaltyRegistry(_royaltyRegistry);
    }

    /**
     * @dev update price only from auction.
     * @param _price price of the token
     * @param _tokenId uint256 id of the token.
     * @param _owner address of the token owner
     */
    function setPrice(uint256 _price, uint256 _tokenId, address _owner) external override {
        require(msg.sender == address(marketAuction), "only market auction can set the price");
        TokenOwnerInfo storage info = tokenOwnerInfo[_tokenId][_owner];
        info.prices.push(_price);
    }

    /**
     * @dev update bids only from auction.
     * @param _bid bid Amount
     * @param _bidder bidder address
     * @param _tokenId uint256 id of the token.
     * @param _owner address of the token owner
     */
    function setBid(uint256 _bid, address _bidder, uint256 _tokenId, address _owner) external override {
        require(msg.sender == address(marketAuction), "only market auction can set the price");
        TokenOwnerInfo storage info = tokenOwnerInfo[_tokenId][_owner];
        info.bids.push(_bid);
        info.bidders.push(_bidder);
    }

    /**
     * @dev Adds a new unique token to the supply.
     * @param _tokenAmount total token amount available
     * @param _isForSale if is for sale
     * @param _priceType 0 is for fixed, 1 is for Auction Time bound, 2 is for Auction Infiniite
     * @param _royaltyPercentage royality percentage of creator
     */
    function addNewToken(uint256 _tokenAmount, bool _isForSale, uint8 _priceType, uint8 _royaltyPercentage) public {
        uint256 tokenId = _createToken(msg.sender, _tokenAmount, _isForSale, 0, _priceType, _royaltyPercentage);

        emit AddNewToken(msg.sender, tokenId);
    }

    /**
     * @dev Adds a new unique token to the supply.
     * @param _tokenAmount total token amount available
     * @param _isForSale if is for sale
     * @param _priceType 0 is for fixed, 1 is for Auction Time bound, 2 is for Auction Infiniite
     * @param _royaltyPercentage royality percentage of creator
     * @param _tokenId uint256 ID of the token.
     */
    function addNewTokenWithId(uint256 _tokenAmount, bool _isForSale, uint8 _priceType, uint8 _royaltyPercentage, uint256 _tokenId) public {
        uint256 tokenId = _createTokenWithId(msg.sender, _tokenAmount, _isForSale, 0, _priceType, _royaltyPercentage, _tokenId);

        emit AddNewToken(msg.sender, tokenId);
    }

    /**
     * @dev add token and set the price.
     * @param _price price of the item.
     * @param _tokenAmount total token amount available
     * @param _isForSale if is for sale
     * @param _priceType 0 is for fixed, 1 is for Auction Time bound, 2 is for Auction Infiniite
     * @param _royaltyPercentage royality percentage of creator
     * @param _startTime start time of bid, pass 0 of _priceType is not 1
     * @param _endTime end time of bid, pass 0 of _priceType is not 1
     */
    function addNewTokenAndSetThePrice(uint256 _tokenAmount, bool _isForSale, uint256 _price, uint8 _priceType, uint8 _royaltyPercentage, uint256 _startTime, uint256 _endTime) public {
        uint256 tokenId = getTokenIdAvailable();
        addNewTokenAndSetThePriceWithId(_tokenAmount, _isForSale, _price, _priceType, _royaltyPercentage, _startTime, _endTime, tokenId);
    }

    /**
     * @dev add token and set the price.
     * @param _price price of the item.
     * @param _tokenAmount total token amount available
     * @param _isForSale if is for sale
     * @param _priceType 0 is for fixed, 1 is for Auction Time bound, 2 is for Auction Infiniite
     * @param _royaltyPercentage royality percentage of creator
     * @param _startTime start time of bid, pass 0 of _priceType is not 1
     * @param _endTime end time of bid, pass 0 of _priceType is not 1
     * @param _tokenId uint256 ID of the token.
     */
    function addNewTokenAndSetThePriceWithId(uint256 _tokenAmount, bool _isForSale, uint256 _price, uint8 _priceType, uint8 _royaltyPercentage, uint256 _startTime, uint256 _endTime, uint256 _tokenId) public {
        uint256 tokenId = _createTokenWithId(msg.sender, _tokenAmount, _isForSale, _price, _priceType, _royaltyPercentage, _tokenId);
        putOnSale(_priceType, _price, _startTime, _endTime, tokenId, msg.sender);

        emit AddNewToken(msg.sender, tokenId);
    }

    /**
     * @dev Deletes the token with the provided ID.
     * @param _tokenId uint256 ID of the token.
     * @param _amount amount of the token to delete
     */
    function deleteToken(uint256 _tokenId, uint256 _amount) public onlyTokenOwner(_tokenId) {
        bool activeBid = marketAuction.hasTokenActiveBid(_tokenId, msg.sender);
        uint256 balance = balanceOf(msg.sender, _tokenId);
        //2
        if (activeBid == true)
            require(balance.sub(_amount) > 0, "you have the active bid");
        _burn(msg.sender, _tokenId, _amount);
        DeleteTokens(msg.sender, _tokenId, _amount);
    }

    /**
     * @dev Sets uri of tokens.
     *
     * Requirements:
     *
     * @param _uri new uri .
     */
    function setURI(string memory _uri) external onlyOwner {
        _setURI(_uri);
        emit SetURI(_uri);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
    public
    virtual
    override
    {
        //transfer case
        if (msg.sender != address(marketAuction)) {
            bool activeBid = marketAuction.hasTokenActiveBid(id, from);
            uint256 balance = balanceOf(from, id);
            if (activeBid == true)
                require(balance.sub(amount) > 0, "you have the active bid");
        }
        super.safeTransferFrom(from, to, id, amount, data);
        _setTokenOwner(id, to);
    }

    /**
     * @dev Internal function for setting the token's creator.
     * @param _tokenId uint256 id of the token.
     * @param _owner address of the owner of the token.
     */
    function _setTokenOwner(uint256 _tokenId, address _owner) internal {
        address[] storage owners = tokenInfo[_tokenId].owners;
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _owner) //incase owner already exists
                return;
        }
        owners.push(_owner);
    }

    /**
     * @dev Internal function creating a new token.
     * @param _creator address of the creator of the token.
     * @param _tokenAmount total token amount available
     * @param _isForSale if is for sale
     * @param _price price of the token, 0 is for not set the price.
     * @param _priceType 0 is for fixed, 1 is for Auction Time bound, 2 is for Auction Infiniite
     * @param _royaltyPercentage royality percentage of creator
     */
    function _createToken(address _creator, uint256 _tokenAmount, bool _isForSale, uint256 _price, uint8 _priceType, uint8 _royaltyPercentage) internal returns (uint256) {
        uint256 newId = getTokenIdAvailable();
        return _createTokenWithId(_creator, _tokenAmount, _isForSale, _price, _priceType, _royaltyPercentage, newId);
    }

    /**
     * @dev Internal function creating a new token.
     * @param _creator address of the creator of the token.
     * @param _tokenAmount total token amount available
     * @param _isForSale if is for sale
     * @param _price price of the token, 0 is for not set the price.
     * @param _priceType 0 is for fixed, 1 is for Auction Time bound, 2 is for Auction Infiniite
     * @param _royaltyPercentage royality percentage of creator
     * @param _tokenId uint256 token id
     */
    function _createTokenWithId(address _creator, uint256 _tokenAmount, bool _isForSale, uint256 _price, uint8 _priceType, uint8 _royaltyPercentage, uint256 _tokenId) internal returns (uint256) {
        require(tokenIdsAvailable[_tokenId] == false, "token id is already exist");

        tokenIdsAvailable[_tokenId] = true;
        tokenIds.push(_tokenId);

        maxId = maxId > _tokenId ? maxId : _tokenId;

        _mint(_creator, _tokenId, _tokenAmount, '');
        uint8 serviceFee = marketplaceSettings.getMarketplaceFeePercentage();

        tokenInfo[_tokenId] = TokenInfo(
            _tokenId,
            _creator,
            _tokenAmount,
            new address[](0),
            serviceFee,
            block.timestamp);

        tokenInfo[_tokenId].owners.push(_creator);

        tokenOwnerInfo[_tokenId][_creator] = TokenOwnerInfo(
            _isForSale,
            _priceType,
            new uint256[](0),
            new uint256[](0),
            new address[](0));
        tokenOwnerInfo[_tokenId][_creator].prices.push(_price);

        royaltyRegistry.setPercentageForTokenRoyalty(_tokenId, _royaltyPercentage);
        tokenCreatorRigistry.setTokenCreator(_tokenId, msg.sender);

        return _tokenId;
    }

    /**
     * @dev get last token id
     */
    function getLastTokenId() external view returns (uint256){
        return tokenIds[tokenIds.length - 1];
    }

    /**
     * @dev get the token id available
     */
    function getTokenIdAvailable() public view returns (uint256){

        for (uint256 i = 0; i < maxId; i++) {
            if (tokenIdsAvailable[i] == false)
                return i;
        }
        return tokenIds.length;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../utils/Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts may inherit from this and call {_registerInterface} to declare
 * their support of an interface.
 */
abstract contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See {IERC165-supportsInterface}.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b > a) return (false, 0);
        return (true, a - b);
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        return a - b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryDiv}.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./IERC1155.sol";
import "./IERC1155MetadataURI.sol";
import "./IERC1155Receiver.sol";
import "../../utils/Context.sol";
import "../../introspection/ERC165.sol";
import "../../math/SafeMath.sol";
import "../../utils/Address.sol";

/**
 *
 * @dev Implementation of the basic standard multi-token.
 * See https://eips.ethereum.org/EIPS/eip-1155
 * Originally based on code by Enjin: https://github.com/enjin/erc-1155
 *
 * _Available since v3.1._
 */
contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {
    using SafeMath for uint256;
    using Address for address;

    // Mapping from token ID to account balances
    mapping (uint256 => mapping(address => uint256)) private _balances;

    // Mapping from account to operator approvals
    mapping (address => mapping(address => bool)) private _operatorApprovals;

    // Used as the URI for all token types by relying on ID substitution, e.g. https://token-cdn-domain/{id}.json
    string private _uri;

    /*
     *     bytes4(keccak256('balanceOf(address,uint256)')) == 0x00fdd58e
     *     bytes4(keccak256('balanceOfBatch(address[],uint256[])')) == 0x4e1273f4
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c5
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,uint256,bytes)')) == 0xf242432a
     *     bytes4(keccak256('safeBatchTransferFrom(address,address,uint256[],uint256[],bytes)')) == 0x2eb2c2d6
     *
     *     => 0x00fdd58e ^ 0x4e1273f4 ^ 0xa22cb465 ^
     *        0xe985e9c5 ^ 0xf242432a ^ 0x2eb2c2d6 == 0xd9b67a26
     */
    bytes4 private constant _INTERFACE_ID_ERC1155 = 0xd9b67a26;

    /*
     *     bytes4(keccak256('uri(uint256)')) == 0x0e89341c
     */
    bytes4 private constant _INTERFACE_ID_ERC1155_METADATA_URI = 0x0e89341c;

    /**
     * @dev See {_setURI}.
     */
    constructor (string memory uri_) public {
        _setURI(uri_);

        // register the supported interfaces to conform to ERC1155 via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155);

        // register the supported interfaces to conform to ERC1155MetadataURI via ERC165
        _registerInterface(_INTERFACE_ID_ERC1155_METADATA_URI);
    }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256) external view virtual override returns (string memory) {
        return _uri;
    }

    /**
     * @dev See {IERC1155-balanceOf}.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {
        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    /**
     * @dev See {IERC1155-balanceOfBatch}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(
        address[] memory accounts,
        uint256[] memory ids
    )
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {
        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    /**
     * @dev See {IERC1155-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public virtual override {
        require(_msgSender() != operator, "ERC1155: setting approval status for self");

        _operatorApprovals[_msgSender()][operator] = approved;
        emit ApprovalForAll(_msgSender(), operator, approved);
    }

    /**
     * @dev See {IERC1155-isApprovedForAll}.
     */
    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[account][operator];
    }

    /**
     * @dev See {IERC1155-safeTransferFrom}.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][from] = _balances[id][from].sub(amount, "ERC1155: insufficient balance for transfer");
        _balances[id][to] = _balances[id][to].add(amount);

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    /**
     * @dev See {IERC1155-safeBatchTransferFrom}.
     */
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        public
        virtual
        override
    {
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");
        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            _balances[id][from] = _balances[id][from].sub(
                amount,
                "ERC1155: insufficient balance for transfer"
            );
            _balances[id][to] = _balances[id][to].add(amount);
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev Sets a new URI for all token types, by relying on the token type ID
     * substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * By this mechanism, any occurrence of the `\{id\}` substring in either the
     * URI or any of the amounts in the JSON file at said URI will be replaced by
     * clients with the token type ID.
     *
     * For example, the `https://token-cdn-domain/\{id\}.json` URI would be
     * interpreted by clients as
     * `https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
     * for token type ID 0x4cce0.
     *
     * See {uri}.
     *
     * Because these URIs cannot be meaningfully represented by the {URI} event,
     * this function emits no events.
     */
    function _setURI(string memory newuri) internal virtual {
        _uri = newuri;
    }

    /**
     * @dev Creates `amount` tokens of token type `id`, and assigns them to `account`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - If `account` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function _mint(address account, uint256 id, uint256 amount, bytes memory data) internal virtual {
        require(account != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), account, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][account] = _balances[id][account].add(amount);
        emit TransferSingle(operator, address(0), account, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), account, id, amount, data);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_mint}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function _mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) internal virtual {
        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] = amounts[i].add(_balances[ids[i]][to]);
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    /**
     * @dev Destroys `amount` tokens of token type `id` from `account`
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens of token type `id`.
     */
    function _burn(address account, uint256 id, uint256 amount) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        _balances[id][account] = _balances[id][account].sub(
            amount,
            "ERC1155: burn amount exceeds balance"
        );

        emit TransferSingle(operator, account, address(0), id, amount);
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {_burn}.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     */
    function _burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) internal virtual {
        require(account != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, account, address(0), ids, amounts, "");

        for (uint i = 0; i < ids.length; i++) {
            _balances[ids[i]][account] = _balances[ids[i]][account].sub(
                amounts[i],
                "ERC1155: burn amount exceeds balance"
            );
        }

        emit TransferBatch(operator, account, address(0), ids, amounts);
    }

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        internal
        virtual
    { }

    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    )
        private
    {
        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (bytes4 response) {
                if (response != IERC1155Receiver(to).onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * @dev Required interface of an ERC1155 compliant contract, as defined in the
 * https://eips.ethereum.org/EIPS/eip-1155[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155 is IERC165 {
    /**
     * @dev Emitted when `value` tokens of token type `id` are transferred from `from` to `to` by `operator`.
     */
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    /**
     * @dev Equivalent to multiple {TransferSingle} events, where `operator`, `from` and `to` are the same for all
     * transfers.
     */
    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    /**
     * @dev Emitted when `account` grants or revokes permission to `operator` to transfer their tokens, according to
     * `approved`.
     */
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    /**
     * @dev Emitted when the URI for token type `id` changes to `value`, if it is a non-programmatic URI.
     *
     * If an {URI} event was emitted for `id`, the standard
     * https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[guarantees] that `value` will equal the value
     * returned by {IERC1155MetadataURI-uri}.
     */
    event URI(string value, uint256 indexed id);

    /**
     * @dev Returns the amount of tokens of token type `id` owned by `account`.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function balanceOf(address account, uint256 id) external view returns (uint256);

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {balanceOf}.
     *
     * Requirements:
     *
     * - `accounts` and `ids` must have the same length.
     */
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);

    /**
     * @dev Grants or revokes permission to `operator` to transfer the caller's tokens, according to `approved`,
     *
     * Emits an {ApprovalForAll} event.
     *
     * Requirements:
     *
     * - `operator` cannot be the caller.
     */
    function setApprovalForAll(address operator, bool approved) external;

    /**
     * @dev Returns true if `operator` is approved to transfer ``account``'s tokens.
     *
     * See {setApprovalForAll}.
     */
    function isApprovedForAll(address account, address operator) external view returns (bool);

    /**
     * @dev Transfers `amount` tokens of token type `id` from `from` to `to`.
     *
     * Emits a {TransferSingle} event.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - If the caller is not `from`, it must be have been approved to spend ``from``'s tokens via {setApprovalForAll}.
     * - `from` must have a balance of tokens of type `id` of at least `amount`.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
     * acceptance magic value.
     */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] version of {safeTransferFrom}.
     *
     * Emits a {TransferBatch} event.
     *
     * Requirements:
     *
     * - `ids` and `amounts` must have the same length.
     * - If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
     * acceptance magic value.
     */
    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

import "./IERC1155.sol";

/**
 * @dev Interface of the optional ERC1155MetadataExtension interface, as defined
 * in the https://eips.ethereum.org/EIPS/eip-1155#metadata-extensions[EIP].
 *
 * _Available since v3.1._
 */
interface IERC1155MetadataURI is IERC1155 {
    /**
     * @dev Returns the URI for token type `id`.
     *
     * If the `\{id\}` substring is present in the URI, it must be replaced by
     * clients with the actual token type ID.
     */
    function uri(uint256 id) external view returns (string memory);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "../../introspection/IERC165.sol";

/**
 * _Available since v3.1._
 */
interface IERC1155Receiver is IERC165 {

    /**
        @dev Handles the receipt of a single ERC1155 token type. This function is
        called at the end of a `safeTransferFrom` after the balance has been updated.
        To accept the transfer, this must return
        `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))`
        (i.e. 0xf23a6e61, or its own function selector).
        @param operator The address which initiated the transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param id The ID of the token being transferred
        @param value The amount of tokens being transferred
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155Received(address,address,uint256,uint256,bytes)"))` if transfer is allowed
    */
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);

    /**
        @dev Handles the receipt of a multiple ERC1155 token types. This function
        is called at the end of a `safeBatchTransferFrom` after the balances have
        been updated. To accept the transfer(s), this must return
        `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))`
        (i.e. 0xbc197c81, or its own function selector).
        @param operator The address which initiated the batch transfer (i.e. msg.sender)
        @param from The address which previously owned the token
        @param ids An array containing ids of each token being transferred (order and length must match values array)
        @param values An array containing amounts of each token being transferred (order and length must match ids array)
        @param data Additional data with no specified format
        @return `bytes4(keccak256("onERC1155BatchReceived(address,address,uint256[],uint256[],bytes)"))` if transfer is allowed
    */
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2 <0.8.0;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

{
  "remappings": [],
  "optimizer": {
    "enabled": true,
    "runs": 200
  },
  "evmVersion": "byzantium",
  "libraries": {},
  "outputSelection": {
    "*": {
      "*": [
        "evm.bytecode",
        "evm.deployedBytecode",
        "abi"
      ]
    }
  }
}
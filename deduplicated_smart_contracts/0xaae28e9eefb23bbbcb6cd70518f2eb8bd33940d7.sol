pragma solidity ^0.4.24;

import "./PhotonTestToken.sol";


/**
 * @title PhotochainMarketplace
 * @dev Marketplace to make and accept offers using PhotonToken
 */
contract PhotochainMarketplace is Ownable {
    /**
     * Event for offer creation logging
     * @param id Generated unique offer id
     * @param seller Addess of seller of the photo
     * @param licenseType Which license is applied on the offer
     * @param photoDigest 256-bit hash of the photo
     * @param price How many tokens to pay to accept the offer
     */
    event OfferAdded(
        bytes32 indexed id,
        address indexed seller,
        uint8 licenseType,
        bytes32 photoDigest,
        uint256 price
    );

    /**
     * Event for offer acceptance logging
     * @param id Offer id to accept
     * @param licensee Address of the account that bought license
     */
    event OfferAccepted(bytes32 indexed id, address indexed licensee);

    /**
     * Event for offer price change
     * @param id Offer id to update
     * @param oldPrice Previous price in tokens
     * @param newPrice New price in tokens
     */
    event OfferPriceChanged(bytes32 indexed id, uint256 oldPrice, uint256 newPrice);

    /**
     * Event for offer cancellation
     * @param id Offer id to cancel
     */
    event OfferCancelled(bytes32 indexed id);

    struct Offer {
        address seller;
        uint8 licenseType;
        bool isCancelled;
        bytes32 photoDigest;
        uint256 price;
    }

    ERC20 public token;

    // List of the offers
    mapping(bytes32 => Offer) public offers;

    // List of offer ids by seller
    mapping(address => bytes32[]) public offersBySeller;

    // List of offer ids by licensee
    mapping(address => bytes32[]) public offersByLicensee;

    modifier onlyValidAddress(address _addr) {
        require(_addr != address(0), "Invalid address");
        _;
    }

    modifier onlyActiveOffer(bytes32 _id) {
        require(offers[_id].seller != address(0), "Offer does not exists");
        require(!offers[_id].isCancelled, "Offer is cancelled");
        _;
    }

    /**
     * @param _token Address of the PhotonToken contract
     */
    constructor(ERC20 _token) public onlyValidAddress(address(_token)) {
        token = _token;
    }

    /**
       @dev Sets accounting token address
     * @param _token Address of the PhotonToken contract
     */
    function setToken(ERC20 _token)
        external
        onlyOwner
        onlyValidAddress(address(_token))
    {
        token = _token;
    }

    /**
     * @dev Add an offer to the marketplace
     * @param _seller Address of the photo author
     * @param _licenseType License type for the offer
     * @param _photoDigest 256-bit hash of the photo
     * @param _price Price of the offer
     */
    function addOffer(
        address _seller,
        uint8 _licenseType,
        bytes32 _photoDigest,
        uint256 _price
    )
        external
        onlyOwner
        onlyValidAddress(_seller)
    {
        bytes32 _id = keccak256(
            abi.encodePacked(
                _seller,
                _licenseType,
                _photoDigest
            )
        );
        require(offers[_id].seller == address(0), "Offer already exists");

        offersBySeller[_seller].push(_id);
        offers[_id] = Offer({
            seller: _seller,
            licenseType: _licenseType,
            isCancelled: false,
            photoDigest: _photoDigest,
            price: _price
        });

        emit OfferAdded(_id, _seller, _licenseType, _photoDigest, _price);
    }

    /**
     * @dev Accept an offer on the marketplace
     * @param _id Offer id
     * @param _licensee Address of the licensee that is buying the photo
     */
    function acceptOffer(bytes32 _id, address _licensee)
        external
        onlyOwner
        onlyValidAddress(_licensee)
        onlyActiveOffer(_id)
    {
        Offer storage offer = offers[_id];

        if (offer.price > 0) {
            require(
                token.transferFrom(_licensee, address(this), offer.price),
                "Token transfer to contract failed"
            );

            require(
                token.transfer(offer.seller, offer.price),
                "Token transfer to seller failed"
            );
        }

        offersByLicensee[_licensee].push(_id);

        emit OfferAccepted(_id, _licensee);
    }

    /**
     * @dev Change price of the offer
     * @param _id Offer id
     * @param _price Price of the offer in tokens
     */
    function setOfferPrice(bytes32 _id, uint256 _price)
        external
        onlyOwner
        onlyActiveOffer(_id)
    {
        uint256 oldPrice = offers[_id].price;

        offers[_id].price = _price;

        emit OfferPriceChanged(_id, oldPrice, _price);
    }

    /**
     * @dev Cancel offer
     * @param _id Offer id
     */
    function cancelOffer(bytes32 _id)
        external
        onlyOwner
        onlyActiveOffer(_id)
    {
        offers[_id].isCancelled = true;

        emit OfferCancelled(_id);
    }

    /**
     * @dev Get list of offers id from a seller
     * @param _seller The address of the seller to find its offers
     * @return Offer ids
     */
    function getOffers(address _seller) external view returns (bytes32[] memory) {
        return offersBySeller[_seller];
    }

    /**
     * @dev Get the offer by id
     * @param _id The offer id
     * @return Offer details
     */
    function getOfferById(bytes32 _id)
        external
        view
        returns (
            address seller,
            uint8 licenseType,
            bool isCancelled,
            bytes32 photoDigest,
            uint256 price
        )
    {
        Offer storage offer = offers[_id];

        seller = offer.seller;
        licenseType = offer.licenseType;
        isCancelled = offer.isCancelled;
        photoDigest = offer.photoDigest;
        price = offer.price;
    }

    /**
     * @dev Get the list of the offers id by a licensee
     * @param _licensee Address of a licensee of offers
     */
    function getLicenses(address _licensee)
        external
        view
        returns (bytes32[] memory)
    {
        return offersByLicensee[_licensee];
    }
}

/**
 *Submitted for verification at Etherscan.io on 2019-08-31
*/

pragma solidity ^0.5.10;

contract Oracle {

     /** Contract Constructor
    * @param ethPrice the starting price of ETH in USD, represented as 150000000 = 150.00 USD
    * @dev The message sender is assigned as the contract administrator
    */
    constructor (uint ethPrice) public {
        admins[msg.sender] = true;
        addAsset("ETHUSD", ethPrice);
    }

    Asset[] public assets;
    uint[8][] private prices; // includes 6 decimal places, 12000000 = 12.000000
    mapping(address => bool) public admins;
    mapping(address => bool) public readers;
    uint public constant UPDATE_TIME_MIN = 18 hours;  // 18
    uint public constant SETTLE_TIME_MIN = 5 days;   // 5
    uint public constant EDIT_TIME_MAX = 30 minutes;   // allows oracle to rectify obvious mistakes
    
    struct Asset {
        bytes32 name;
        uint8 currentDay;
        uint lastUpdateTime;
        uint lastSettleTime;
        bool isFinalDay;
    }


    event AssetAdded(
        uint indexed id,
        bytes32 name,
        uint price
    );


    event PriceUpdated(
        uint indexed id,
        bytes32 indexed name,
        uint price,
        uint timestamp,
        uint8 dayNumber
    );

        event PriceCorrected(
        uint indexed id,
        bytes32 indexed name,
        uint price,
        uint timestamp,
        uint8 dayNumber
    );

        modifier onlyAdmin()
    {
        require(admins[msg.sender]);
        _;
    }

     /** Grant administrator priviledges to a user
    * @param newAdmin the address to promote
    */
    function addAdmin(address newAdmin)
        public
        onlyAdmin
    {
        admins[newAdmin] = true;
    }

    /** Add a new asset tracked by the Oracle
    * @param _name the plaintext name of the asset
    * @param _startPrice the starting price of the asset in USD * 10^6, eg 120000 = $0.120000
    * @dev this should usually be called on a Settlement Day
    * @return id the newly assigned ID of the asset
    */
    function addAsset(bytes32 _name, uint _startPrice)
        public
        returns (uint _assetID)
    {
        require (admins[msg.sender] || msg.sender == address(this));
        // Fill the asset struct
        Asset memory asset;
        asset.name = _name;
        asset.currentDay = 0;
        asset.lastUpdateTime = now;
        asset.lastSettleTime = now - 5 days;
        assets.push(asset);
        uint[8] memory _prices;
        _prices[0] = _startPrice;
        prices.push(_prices);
        emit AssetAdded(assets.length - 1, _name, _startPrice);
        return assets.length - 1;
    }


    /** Quickly fix an erroneous price
    * @param _assetID the id of the asset to change
    * @param _newPrice the new price to change to
    * @dev this must be called within 30 minutes of the lates price update occurence
    */
    
    function editPrice(uint _assetID, uint _newPrice)
        public
        onlyAdmin
    {
        Asset storage asset = assets[_assetID];
        require(now < asset.lastUpdateTime + EDIT_TIME_MAX);
        prices[_assetID][asset.currentDay] = _newPrice;
        emit PriceCorrected(_assetID, asset.name, _newPrice, now, asset.currentDay);
    }

    /** Grant an address permision to access private information about the assets
    * @param newReader the address of the account to grant reading priviledges
    * @dev this allows the reader to use the getCurrentPricesFunction
    */
    function addReader(address newReader)
        public
        onlyAdmin
    {
        readers[newReader] = true;
    }

    /** Return the entire current price array for a given asset
    * @param _assetID the asset id of the desired asset
    * @return _priceHist the price array for the asset
    * @dev only the admin and addresses granted readership may call this function
    */
    function getAllPrices(uint _assetID)
        public
        view
        returns (uint[8] memory _priceHist)
    {
        require (admins[msg.sender] || readers[msg.sender]);
        _priceHist = prices[_assetID];
    }

    /** Return only the latest prices
    * @param _assetID the asset id of the desired asset
    * @return _price the latest price of the given asset
    * @dev only the admin or a designated reader may call this function
    */
    function getCurrentPrice(uint _assetID)
        public
        view
        returns (uint _price)
    {
        require (admins[msg.sender] || readers[msg.sender]);
        _price =  prices[_assetID][assets[_assetID].currentDay];
    }

    /** Get the timestamp of the last price update time
    * @param _assetID the asset id of the desired asset
    * @return timestamp the price update timestamp
    */
    function getLastUpdateTime(uint _assetID)
        public
        view
        returns (uint timestamp)
    {
        timestamp = assets[_assetID].lastUpdateTime;
    }

    /** Get the timestamp of the last settle update time
    * @param _assetID the asset id of the desired asset
    * @return timestamp the settle timestamp
    */
    function getLastSettleTime(uint _assetID)
        public
        view
        returns (uint timestamp)
    {
        timestamp = assets[_assetID].lastSettleTime;
    }
    /**
    * @param _assetID the asset id of the desired asset
    * pulls the day relevant for new AssetSwap takes
    */
    function getStartDay(uint _assetID)
        public
        view
        returns (uint8 _startDay)
    {
        if (assets[_assetID].isFinalDay) _startDay = 7;
        else if (assets[_assetID].currentDay == 7) _startDay = 1;
        else _startDay = assets[_assetID].currentDay + 1;
    }

     /** Show if the current day is the final price update before settle
    * @param _assetID the asset id of the desired asset
    * @return true if it is the final day, false otherwise
    * This makes sure the oracle cannot sneak it a settlement unaware
    */
    function isFinalDay(uint _assetID)
        public
        view
        returns (bool)
    {
        return assets[_assetID].isFinalDay;
    }

    /** Show if the last price update was a settle price update
    * @param _assetID the asset id of the desired asset
    * @return true if the last update was a settle, false otherwise
    */
    function isSettleDay(uint _assetID)
        public
        view
        returns (bool)
    {
        return (assets[_assetID].currentDay == 7);
    }

    /** Remove administrator priviledges from a user
    * @param toRemove the address to demote
    * @notice you may not remove yourself
    */
    function removeAdmin(address toRemove)
        public
        onlyAdmin
    {
        require(toRemove != msg.sender);
        admins[toRemove] = false;
    }

      /** Publishes an asset price. Does not initiate a settlement.
    * @param _assetID the ID of the asset to update
    * @param _price the current price of the asset * 10^6
    * @param finalDayStatus true if this is the last intraweek price update (the next will be a settle)
    * @dev this can only be called after the required time has elapsed since the most recent price update
    * @dev if finalDayStatus is true this function cannot be called again until after settle
    */
    function intraWeekPrice(uint _assetID, uint _price, bool finalDayStatus)
        public
        onlyAdmin
    {
        Asset storage asset = assets[_assetID];
        // Prevent price update too early
      require(now > asset.lastUpdateTime + UPDATE_TIME_MIN);
    require(!asset.isFinalDay);
        if (asset.currentDay == 7) {
             asset.currentDay = 1;
             uint[8] memory newPrices;
             newPrices[0] = prices[_assetID][7];
             newPrices[1] = _price;
             prices[_assetID] = newPrices;
        } else {
            asset.currentDay = asset.currentDay + 1;
            prices[_assetID][asset.currentDay] = _price;
            asset.isFinalDay = finalDayStatus;
        }
        asset.lastUpdateTime = now;
        emit PriceUpdated(_assetID, asset.name, _price, now, asset.currentDay);
    }
    
        /** Publishes an asset price. Does not initiate a settlement.
    * @param _assetID the ID of the asset to update
    * @param _price the current price of the asset * 10^6
    * @dev this can only be called after the required time has elapsed since the most recent price update
    * @dev if finalDayStatus is true this function cannot be called again until after settle
    */
    function settlePrice(uint _assetID, uint _price)
        public
        onlyAdmin
    {
        Asset storage asset = assets[_assetID];
        // Prevent price update too early
        require(now > asset.lastUpdateTime + UPDATE_TIME_MIN);
        require(asset.isFinalDay);
        require(now > asset.lastSettleTime + SETTLE_TIME_MIN,
            "Sufficient time must pass between weekly price updates.");
             asset.currentDay = 7;
             prices[_assetID][7] = _price;
             asset.lastSettleTime = now;
             asset.isFinalDay = false;
        asset.lastUpdateTime = now;
        emit PriceUpdated(_assetID, asset.name, _price, now, 7);
        
    }

}
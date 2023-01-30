/**
 *Submitted for verification at Etherscan.io on 2019-08-08
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
    uint[8][] public lastWeekPrices; // includes 6 decimal places, 120000000 = 12.000000
    mapping(address => bool) public admins;
    mapping(address => bool) public readers;
    uint constant DAILY_PRICE_TIME_MIN = 18 hours;  
    uint constant WEEKLY_PRICE_TIME_MIN = 5 days;    
    uint constant EDIT_PRICE_TIME_MAX = 45 minutes;   // allows oracle to rectify obvious mistakes
    
    struct Asset {
        bytes32 name;
        uint lastPriceUpdateTime;
        uint lastSettlePriceTime;
        uint8 currentDay;
        bool isFinalDay;
    }
    
    event AssetAdded(
        uint indexed id,
        bytes32 name,
        uint price
    );

    event PriceUpdated(
        uint indexed id,
        bytes32 name,
        uint price,
        uint timestamp,
        uint8 dayNumber
    );

    event SettlePrice(
        uint indexed id,
        bytes32 name,
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
        returns (uint id2)
    {
        require (admins[msg.sender] || msg.sender == address(this));
        // Fill the asset struct
        Asset memory asset;
        asset.name = _name;
        asset.currentDay = 0;
        asset.lastPriceUpdateTime = now;
        asset.lastSettlePriceTime = now - 5 days;
        assets.push(asset);
        // set up price array and LR
        uint[8] memory _prices;
        lastWeekPrices.push(_prices);
        _prices[0] = _startPrice;
        prices.push(_prices);
        emit AssetAdded(assets.length - 1, _name, _startPrice);
        emit PriceUpdated(assets.length - 1, _name, _startPrice, now, asset.currentDay);
        return assets.length - 1;
    }
    

    /** Quickly fix an erroneous price
    * @param assetID the id of the asset to change
    * @param newPrice the new price to change to
    * @dev this must be called within 30 minutes of the lates price update occurence
    */
    function editPrice(uint assetID, uint newPrice)
        public
        onlyAdmin
    {
        Asset storage asset = assets[assetID];
        require(now < asset.lastPriceUpdateTime + EDIT_PRICE_TIME_MAX);
        prices[assetID][asset.currentDay] = newPrice;
        emit PriceUpdated(assetID, asset.name, newPrice, now, asset.currentDay);
        emit PriceCorrected(assetID, asset.name, newPrice, now, asset.currentDay);
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
    * @param id the asset id of the desired asset
    * @return currentPrices the price array for the asset
    * @dev only the admin and addresses granted readership may call this function
    */
    function getCurrentPrices(uint id)
        public
        view
        returns (uint[8] memory currentPrices)
    {
        require (admins[msg.sender] || readers[msg.sender]);
        currentPrices = prices[id];
    }

    /** Return only the latest prices
    * @param id the asset id of the desired asset
    * @return price the latest price of the given asset
    * @dev only the admin or a designated reader may call this function
    */
    function getCurrentPrice(uint id)
        public
        view
        returns (uint price)
    {
        require (admins[msg.sender] || readers[msg.sender]);    
        price =  prices[id][assets[id].currentDay];
    }

    /** Get the timestamp of the last price update time
    * @param id the asset id of the desired asset
    * @return timestamp the price update timestamp
    */
    function getLastUpdateTime(uint id)
        public
        view
        returns (uint timestamp)
    {
        timestamp = assets[id].lastPriceUpdateTime;
    }

    /** Get the timestamp of the last settle update time
    * @param id the asset id of the desired asset
    * @return timestamp the settle timestamp
    */
    function getLastSettleTime(uint id)
        public
        view
        returns (uint timestamp)
    {
        timestamp = assets[id].lastSettlePriceTime;
    }
    /*
    * used it setting the starting price on Take
    * setting to 7 tells settlment to ignore for that settlement, as the settlement would be it's start price
    */
    function getPriceDay(uint id)
        public
        view
        returns (uint8 currentday)
    {
        if (assets[id].isFinalDay) currentday = 7;
        else currentday = assets[id].currentDay + 1;
    }
    
    /** Show if the current day is the final price update before settle
    * @param id the asset id of the desired asset
    * @return true if it is the final day, false otherwise
    */
    function isFinalDay(uint id)
        public
        view
        returns (bool)
    {
        return assets[id].isFinalDay;
    }
    
    /** Show if the last price update was a settle price update
    * @param id the asset id of the desired asset
    * @return true if the last update was a settle, false otherwise
    * This makes sure the oracle cannot sneak it a settlement unaware
    */
    function isSettleDay(uint id)
        public
        view
        returns (bool)
    {
        return (assets[id].currentDay == 0);
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
    * @param assetID the ID of the asset to update
    * @param price the current price of the asset * 10^6
    * @param finalDayStatus true if this is the last intraweek price update (the next will be a settle)
    * @dev this can only be called after the required time has elapsed since the most recent price update
    * @dev if finalDayStatus is true this function cannot be called again until after settle
    */ 
    function setIntraweekPrice(uint assetID, uint price, bool finalDayStatus)
        public
        onlyAdmin
    {
        Asset storage asset = assets[assetID];        
        // Prevent price update too early
        require(now > asset.lastPriceUpdateTime + DAILY_PRICE_TIME_MIN);
        require(!asset.isFinalDay);
        asset.currentDay = asset.currentDay + 1;
        asset.lastPriceUpdateTime = now;
        prices[assetID][asset.currentDay] = price;
        asset.isFinalDay = finalDayStatus;
        emit PriceUpdated(assetID, asset.name, price, now, asset.currentDay);
    }
    
    
    /** Publishes a new asset price while updating data for a new week of prices
    * @param assetID the id of the asset to update
    * @param price the current price of the asset * 10^6
    * @dev Moves the current prices into LastWeekPrices, overwriting them
    */
    function setSettlePrice(uint assetID, uint price)
        public
        onlyAdmin
    {
        Asset storage asset = assets[assetID];
        // Timing restrictions to prevent oracle cheating
        require(now > asset.lastPriceUpdateTime + DAILY_PRICE_TIME_MIN);
        require(now > asset.lastSettlePriceTime + WEEKLY_PRICE_TIME_MIN);
        require(asset.isFinalDay);
        // push current prices into previous week
        lastWeekPrices[assetID] = prices[assetID];
        // Set up new price array
        asset.currentDay = 0;
        uint[8] memory newPrices;
        newPrices[0] = price;
        prices[assetID] = newPrices;
        asset.lastPriceUpdateTime = now;
        asset.lastSettlePriceTime = now;
        asset.isFinalDay = false;
        emit PriceUpdated(assetID, asset.name, price, now, asset.currentDay);
        emit SettlePrice(assetID, asset.name, price, now, asset.currentDay);
    }
    
}
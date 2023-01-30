/**
 *Submitted for verification at Etherscan.io on 2019-09-06
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
    uint[8][] private prices; 
    mapping(address => bool) public admins;
    mapping(address => bool) public readers;
    //  This prevents the Oracle from sneaking in an unexpected settlement price, especially a rapid succession of them
    // it is 20 hours to accomodate a situation where there is an exogenous circumstance preventing the update, eg, network problems
    uint public constant UPDATE_TIME_MIN = 20 hours;  
    // this prevents settlemen prices from being posted unexpectedly, too quickly
    uint public constant SETTLE_TIME_MIN = 5 days;   
    // this allows the oracle to rectify honest errors that might accidentally be posted
    uint public constant EDIT_TIME_MAX = 30 minutes;  
    
    struct Asset {
        bytes32 name;
        uint8 currentDay;
        uint lastUpdateTime;
        uint lastSettleTime;
        bool isFinalDay;
    }

    event PriceUpdated(
        uint indexed id,
        bytes32 indexed name,
        uint price,
        uint timestamp,
        uint8 dayNumber,
        bool isCorrection
    );

        modifier onlyAdmin()
    {
        require(admins[msg.sender]);
        _;
    }

    /** Grant administrator priviledges to a user, 
    * mainly intended for when the admin wants to switch accounts, ie, paired with a removal
    * @param newAdmin the address to promote
    */
    function addAdmin(address newAdmin)
        public
        onlyAdmin
    {
        admins[newAdmin] = true;
    }

    /** Add a new asset tracked by the Oracle
    * @param _name the hexadecimal version of the simple name
    * plaintext name of the asset, eg, SPXUSD = 0x5350585553440000000000000000000000000000000000000000000000000000
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
        emit PriceUpdated(_assetID, asset.name, _newPrice, now, asset.currentDay, true);
    }

    /** Grant an address permision to access private information about the assets
    * @param newReader the address of the account to grant reading priviledges, 
    * any new contract the Oracle services would thus need the Oracle's permission
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
    function getPrices(uint _assetID)
        public
        view
        returns (uint[8] memory _priceHist)
    {
        require (admins[msg.sender] || readers[msg.sender]);
        _priceHist = prices[_assetID];
    }
    
    /** Return the current prices array for a given asset
     * excepting the last one. This is useful for users trying to calculate their PNL, as holidays can make
     * inferences about the settlement or start date ambiguous. Anyone trying to use this contract as an oracle, however, 
     * would have a day lag
    * @param _assetID the asset id of the desired asset
    * @return _priceHist the price array for the asset excluding the most recent observation
    * @dev only the admin and addresses granted readership may call this function
    */
    function getStalePrices(uint _assetID)
        public
        view
        returns (uint[8] memory _priceHist)
    {
        _priceHist = prices[_assetID];
        _priceHist[assets[_assetID].currentDay]=0;
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
    * this is useful for knowing when to run the WeeklyReturns function, and that settlement is soon
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
    * This makes sure the oracle cannot sneak it a settlement unaware, as when flagged false a user knows that a 
    * settlement cannot occur for at least 2 days. When set to false it lets a user know the next price update will be a
    * settlement price and they need to potentially cure or cancel
    */
    function isPenultimateUpdate(uint _assetID)
        public
        view
        returns (bool)
    {
        return assets[_assetID].isFinalDay;
    }

    /** Show if the last price update was a settle price update
    * @param _assetID the asset id of the desired asset
    * @return true if the last update was a settle, false otherwise
    * This tells LPs they need to settle their books, and that all parties must  cure their margin if needed
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
    * @notice you may not remove yourself. This allows the oracle to deprecate old addresses
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
        // Prevent a quick succession of price updates
        require(now > asset.lastUpdateTime + UPDATE_TIME_MIN);
        // the price update follawing the isFinalDay=true must be a settlement price
        require(!asset.isFinalDay);
        if (asset.currentDay == 7) {
             asset.currentDay = 1;
             uint[8] memory newPrices;
             // the start price for each week is the settlement price of the prior week
             newPrices[0] = prices[_assetID][7];
             newPrices[1] = _price;
             prices[_assetID] = newPrices;
        } else {
            asset.currentDay = asset.currentDay + 1;
            prices[_assetID][asset.currentDay] = _price;
            asset.isFinalDay = finalDayStatus;
        }
        asset.lastUpdateTime = now;
        emit PriceUpdated(_assetID, asset.name, _price, now, asset.currentDay, false);
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
        // can only be set when the last update signalled as such
        require(asset.isFinalDay);
        // need at least 5 days between settlements
        require(now > asset.lastSettleTime + SETTLE_TIME_MIN,
            "Sufficient time must pass between weekly price updates.");
            // settlement prices are set to slot 7 in the prices array
             asset.currentDay = 7;
             prices[_assetID][7] = _price;
             asset.lastSettleTime = now;
             asset.isFinalDay = false;
        asset.lastUpdateTime = now;
        emit PriceUpdated(_assetID, asset.name, _price, now, 7, false);
        
    }

}
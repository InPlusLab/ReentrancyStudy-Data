/**
 *Submitted for verification at Etherscan.io on 2019-09-20
*/

// File: browser/Oracle.sol

pragma solidity ^0.5.11;

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
    uint public constant UPDATE_TIME_MIN = 0 hours;
    // this gives time for players to cure their margins, burn
    uint public constant SETTLE_TIME_MIN1 = 0 days;    // 1 day
    // this prevents addition of new prices before settlements are completed
    uint public constant SETTLE_TIME_MIN2 = 46 hours;   // 46
    // this allows the oracle to rectify honest errors that might accidentally be posted
    uint public constant EDIT_TIME_MAX = 30 minutes;  // 90 min

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
    * @param _startPrice the starting price of the asset in USD * 10^2, eg 1200 = $12.00
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
    * @param _price the current price of the asset * 10^2
    * @param finalDayStatus true if this is the last intraweek price update (the next will be a settle)
    * @dev this can only be called after the required time has elapsed since the most recent price update
    * @dev if finalDayStatus is true this function cannot be called again until after settle
    */
    function setIntraWeekPrice(uint _assetID, uint _price, bool finalDayStatus)
        public
        onlyAdmin
    {
        Asset storage asset = assets[_assetID];
        // Prevent a quick succession of price updates
        require(now > asset.lastUpdateTime + UPDATE_TIME_MIN);
        // the price update follawing the isFinalDay=true must be a settlement price
        require(!asset.isFinalDay);
        if (asset.currentDay == 7) {
            require(now > asset.lastSettleTime + SETTLE_TIME_MIN2,
                "Sufficient time must pass after settlement update.");
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
    * @param _price the current price of the asset * 10^2
    * @dev this can only be called after the required time has elapsed since the most recent price update
    * @dev if finalDayStatus is true this function cannot be called again until after settle
    */
    function setSettlePrice(uint _assetID, uint _price)
        public
        onlyAdmin
    {
        Asset storage asset = assets[_assetID];
        // Prevent price update too early
        require(now > asset.lastUpdateTime + UPDATE_TIME_MIN);
        // can only be set when the last update signalled as such
        require(asset.isFinalDay);
        // need at least 5 days between settlements
        require(now > asset.lastSettleTime + SETTLE_TIME_MIN1,
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

// File: browser/Book.sol


pragma solidity ^0.5.11;

contract Book {

    /** Sets up a new Book for an LP.
    * @notice each LP should have only one book
    * @dev the minumum take size is established here and never changes
    * @param user the address of the LP the new book should belong to
    * @param admin gives the AssetSwap contract the right to read and write to this contract
    * @param minBalance the minimum balance size in finney
    */
     constructor(address user, address  admin, uint minBalance)
        public
    {
        assetSwap = AssetSwap(admin);
        lp = user;
        minRM = minBalance * 1 finney;
        lastBookSettleTime = now - 7 days;
    }

    address public lp;
    AssetSwap public assetSwap;
    bool public bookDefaulted;
    uint public settleNum;
    uint public LPMargin;
    uint public LPLongMargin;    // total RM of all subks where lp is long
    uint public LPShortMargin;   // total RM of all subks where lp is short
    uint public LPRequiredMargin;   // ajusted by take, reset at settle
    uint public lastBookSettleTime;
    uint public minRM;
    uint public debitAcct;
    uint internal constant BURN_DEF_FEE = 2; // burn and default fee, applied as RM/BURN_DEF_FEE
    //  after 9 days without an Oracle settlement, all players can redeem their contracts
    //  after one player executes the invactiveOracle function, which uses this constant, the book is in default allowing
    // anyone to redeem their subcontracts and withdraw their margin
    uint internal constant ORACLE_MAX_ABSENCE = 1 days;
    // as long and short settlements are executed separately, prevents the oracle
    // from settling either side twice on settlement day
    uint internal constant NO_DOUBLE_SETTLES = 1 days;
    // settlement uses gas, and so this max prevents the accumulation of so many subcontracts the Book could never settle
    uint internal constant MAX_SUBCONTRACTS = 225;
    uint internal constant CLOSE_FEE = 200;
    uint internal constant LP_MAX_SETTLE = 0 days;
    bytes32[] public shortTakerContracts; // note this implies the lp is long
    bytes32[] public longTakerContracts;  // and here the  lp is short
    mapping(bytes32 => Subcontract) public subcontracts;
    address payable internal constant BURN_ADDRESS = address(0xdead);  // address payable

    struct Subcontract {
        uint index;
		address taker;
		uint takerMargin;   // in wei
		uint reqMargin;     // in wei
        uint8 startDay;     // 0 for initial price on settlement, 1 for day after, etc, though 7 implies settlement day
        bool takerCloseDisc;
		bool LPSide;        // true for LP long, taker Short
		bool isCancelled;
		bool takerBurned;
		bool LPBurned;
		bool takerDefaulted;
        bool isActive;
	}


    modifier onlyAdmin()
    {
        require(msg.sender == address(assetSwap));
        _;
    }

    /** Allow the LP to change the minimum take size in their book
    * @param _min the minimum take size in ETH for the book
    */
    function adjustMinRM(uint _min)
        public
        onlyAdmin
    {
        minRM = _min * 1 finney;
    }

    /** Allow the OracleSwap admin to cancel any  subcontract
    * @param subkID the subcontract to cancel
    */
    function adminCancel(bytes32 subkID)
        public
        payable
        onlyAdmin
    {
        Subcontract storage k = subcontracts[subkID];
        k.isCancelled = true;
    }

    /** Allow the OracleSwap admin to cancel any  subcontract
    */
    function adminStop()
        public
        payable
        onlyAdmin
    {
        bookDefaulted = true;
        LPRequiredMargin = 0;
    }

    /** Function to send balances back to the Assetswap contract
    * @param amount the amount in wei to send
    * @param recipient the address to credit the balance to
    */
    function balanceSend(uint amount, address recipient)
        internal
    {
        assetSwap.balanceTransfer.value(amount)(recipient);
    }

    /** Burn a subcontract
    * @param subkID the subcontract id
    * @param sender who called the function in AssetSwap
    * @param amount the message value
    */
    function bookBurn( bytes32 subkID, address sender, uint amount)
        public
        payable
        onlyAdmin
        returns (uint)
    {
        Subcontract storage k = subcontracts[subkID];
        require(sender == lp || sender == k.taker, "must by party to his subcontract");
        // cost to burn
		uint burnFee = k.reqMargin / BURN_DEF_FEE;
		require (amount >= burnFee);
		if (sender == lp)
		    k.LPBurned = true;
		else
		    k.takerBurned = true;
		return burnFee;
    }

     /** Cancel a subcontract
    * @param lastOracleSettleTime the last settle price timestamp
    * @param subkID the subcontract id
    */
    function bookCancel(uint lastOracleSettleTime, bytes32 subkID, address sender)
        public
        payable
        onlyAdmin
    {
        Subcontract storage k = subcontracts[subkID];
        require(lastOracleSettleTime < lastBookSettleTime, "Cannot do during settle period");
		require(sender == k.taker || sender == lp, "Canceller not LP or taker");
        require(!k.isCancelled, "Subcontract already cancelled");
        uint fee;
        fee =(k.reqMargin * CLOSE_FEE)/1e4 ;
        if (k.takerCloseDisc || (sender == lp))
           fee = 3 * fee / 2;
		require(msg.value >= fee, "Insufficient cancel fee");
        k.isCancelled = true;
        balanceSend(msg.value - fee, sender);
        balanceSend(fee, assetSwap.feeAddress());
    }

    /** Deposit ETH into the LP margin
    * @notice the message value is directly deposited
    */
    function fundLPMargin()
        public
        payable
    {
        LPMargin = add(LPMargin,msg.value);
    }

    /** Deposit ETH into a taker's margin
    * @param subkID the id of the subcontract to deposit into
    * @notice the message value is directly deposited.
    */
    function fundTakerMargin(bytes32 subkID)
        public
        payable
    {
        Subcontract storage k = subcontracts[subkID];
        require (k.reqMargin > 0);
        k.takerMargin= add(k.takerMargin,msg.value);
    }

    /** This function returns the stored values of a subcontract
    * @param subkID the subcontract id
    * @return takerMargin the takers actual margin balance
    * @return reqMargin the required margin for both parties for the subcontract
    * @return startDay the integer value corresponding to the index (day) for retrieving prices
    * @return LPSide, the side of the contract in terms of the LP, eg, true implies lp is long, taker is short
    * @return takerCloseFee, as these depend on the size of the LP book when taken relative to the AssetSwap's Global_size_discout
    * that distinguishes between large and small lps for this assetswap, where larger LP books have half the closing fee that
    * small LP books have
    *
    */
        function getSubkData(bytes32 subkID)
        public
        view
        returns (uint _takerMargin, uint _reqMargin,
          bool _lpside, bool isCancelled, bool isActive, uint8 _startDay)
    {
        Subcontract storage k = subcontracts[subkID];
        _takerMargin = k.takerMargin;
        _reqMargin = k.reqMargin;
        _lpside = k.LPSide;
        isCancelled = k.isCancelled;
        isActive = k.isActive;
        _startDay = k.startDay;
    }


    /** This function returns the stored values of a subcontract
    *
    */

      function getSubkDetail(bytes32 subkID)
        public
        view
        returns (bool closeDisc, bool takerBurned, bool LPBurned, bool takerDefaulted)
    {
        Subcontract storage k = subcontracts[subkID];
        closeDisc = k.takerCloseDisc;
        takerBurned = k.takerBurned;
        LPBurned = k.LPBurned;
        takerDefaulted = k.takerDefaulted;
    }


    /** if the Oracle neglects the OracleContract, any player can set the book into default by executing this function
     * then all players can redeem their subcontracts
     *
     */

     function inactiveOracle()
        public
        {
          require(now > (lastBookSettleTime + ORACLE_MAX_ABSENCE));

          bookDefaulted = true;
          LPRequiredMargin = 0;
        }

    /** if the book was not settled, the LP is held accountable
     * the first counterparty to execute this function will then get a bonus credit of their RM from the LP
     * if the LP's total margin is zero, they will get whatever is there
     * after the book is in default all players can redeem their subcontracts
     * After a book is in default, this cannot be executed
     */

    function inactiveLP(uint _lastOracleSettleTime, bytes32 subkID)
        public
    {
          require(_lastOracleSettleTime > lastBookSettleTime);
          require( now > (_lastOracleSettleTime + LP_MAX_SETTLE));
          require(!bookDefaulted);
          Subcontract storage k = subcontracts[subkID];
          uint LPfee = min(LPMargin,k.reqMargin);
          uint defPay = subzero(LPRequiredMargin/2,LPfee);
          LPMargin = subzero(LPMargin,add(LPfee,defPay));
          k.takerMargin = add(k.takerMargin,LPfee);
          bookDefaulted = true;
          LPRequiredMargin = 0;
    }
    /** Refund the balances and remove from storage a subcontract that has been defaulted, cancelled,
    * burned, or expired.
    * @param subkID the id of the subcontract
    * this is done separately from settlement because it requires a modest amount of gas
    * and would otherwise severely reduce the number of potential long and short contracts
    */
    function redeemSubcontract(bytes32 subkID)
        public
        onlyAdmin
    {
        Subcontract storage k = subcontracts[subkID];
        require(!k.isActive || bookDefaulted);
        uint tMargin = k.takerMargin;
        if (k.takerDefaulted) {
            uint defPay = k.reqMargin / BURN_DEF_FEE;
            tMargin = subzero(tMargin,defPay);
        BURN_ADDRESS.transfer(defPay);
        }
        k.takerMargin = 0;
        balanceSend(tMargin, k.taker);
        uint index = k.index;
        if (k.LPSide) {
            Subcontract storage lastShort = subcontracts[shortTakerContracts[shortTakerContracts.length - 1]];
            lastShort.index = index;
            shortTakerContracts[index] = shortTakerContracts[shortTakerContracts.length - 1];
            shortTakerContracts.pop();
        } else {
            Subcontract storage lastLong = subcontracts[longTakerContracts[longTakerContracts.length - 1]];
            lastLong.index = index;
            longTakerContracts[index] = longTakerContracts[longTakerContracts.length - 1];
            longTakerContracts.pop();
        }
        Subcontract memory blank;
        subcontracts[subkID] = blank;
    }

    /** Settle the taker long sukcontracts
    * @param takerLongRets the returns for a long contract for a taker for each potential startDay
    * */
  function settleLong(int[8] memory takerLongRets, uint topLoop)
        public
        onlyAdmin
    {
        // long settle can only be done once at settlement
       require(settleNum < longTakerContracts.length);
       // settlement can only be done at least 5 days since the last settlement
       require(now > lastBookSettleTime + NO_DOUBLE_SETTLES);
       topLoop = min(longTakerContracts.length, topLoop);
        LPRequiredMargin = add(LPLongMargin,LPShortMargin);
         for (settleNum; settleNum < topLoop; settleNum++) {
             settleSubcontract(longTakerContracts[settleNum], takerLongRets);
        }
    }

    /** Settle the taker long sukcontracts
    * @param takerShortRets the returns for a long contract for a taker for each potential startDay
    * */
 function settleShort(int[8] memory takerShortRets, uint topLoop)
        public
        onlyAdmin
    {
        require(settleNum >= longTakerContracts.length);
        topLoop = min(shortTakerContracts.length, topLoop);
        for (uint i = settleNum - longTakerContracts.length; i < topLoop; i++) {
             settleSubcontract(shortTakerContracts[i], takerShortRets);
        }
        settleNum = topLoop + longTakerContracts.length;
        
        if (settleNum == longTakerContracts.length + shortTakerContracts.length) {
            LPMargin = subzero(LPMargin,debitAcct);
            if (LPShortMargin > LPLongMargin) LPRequiredMargin = subzero(LPShortMargin,LPLongMargin);
                else LPRequiredMargin = subzero(LPLongMargin,LPShortMargin);
            debitAcct = 0;
            lastBookSettleTime = now;
            settleNum = 0;
            if (LPMargin < LPRequiredMargin) {
                bookDefaulted = true;
                uint defPay = min(LPMargin, LPRequiredMargin/BURN_DEF_FEE);
                LPMargin = subzero(LPMargin,defPay);
            }
        }
    }

     function MarginCheck()
        public
        view
        returns (uint playerMargin, uint bookETH)
    {
        playerMargin = 0;

            for (uint i = 0; i < longTakerContracts.length; i++) {
             Subcontract storage k = subcontracts[longTakerContracts[i]];
             playerMargin = playerMargin + k.takerMargin ;
            }
             for (uint i = 0; i < shortTakerContracts.length; i++) {
             Subcontract storage k = subcontracts[shortTakerContracts[i]];
             playerMargin = playerMargin + k.takerMargin ;
            }

            playerMargin  = playerMargin + LPMargin;
            bookETH = address(this).balance;


    }

      /** Internal fn to settle an individual subcontract
    * @param subkID the id of the subcontract
    * @param subkRets the taker returns for a contract of that position for each day of the week
    */


    function settleSubcontract(bytes32 subkID, int[8] memory subkRets)
     internal
    {
        Subcontract storage k = subcontracts[subkID];
        // Don't settle terminated contracts or just starting subcontracts
        if (k.isActive && (k.startDay != 7)) {

            uint absolutePNL;

            bool lpprof;
            if (subkRets[k.startDay] < 0) {
                lpprof = true;
                absolutePNL = uint(-1 * subkRets[k.startDay]) * k.reqMargin / 1 finney;
            }
            else {
                absolutePNL = uint(subkRets[k.startDay]) * k.reqMargin / 1 finney;
            }
            absolutePNL = min(k.reqMargin,absolutePNL);
            if (lpprof) {
                k.takerMargin = subzero(k.takerMargin,absolutePNL);
                if (!k.takerBurned) LPMargin = add(LPMargin,absolutePNL);
            } else {
                if (absolutePNL>LPMargin) debitAcct = add(debitAcct,subzero(absolutePNL,LPMargin));
                LPMargin = subzero(LPMargin,absolutePNL);
                if (!k.LPBurned) k.takerMargin = add(k.takerMargin,absolutePNL);
            }
            if (k.LPBurned || k.takerBurned || k.isCancelled) {
                if (k.LPSide) LPLongMargin = subzero(LPLongMargin,k.reqMargin);
                else LPShortMargin = subzero(LPShortMargin,k.reqMargin);
                k.isActive = false;
            } else if (k.takerMargin < k.reqMargin)
            {
                if (k.LPSide) LPLongMargin = subzero(LPLongMargin,k.reqMargin);
                else LPShortMargin = subzero(LPShortMargin,k.reqMargin);
                k.isActive = false;
                k.takerDefaulted = true;
            }
        }
        k.startDay = 0;
    }


      /** Create a new Taker long subcontract of the given parameters
    * @param taker the address of the party on the other side of the contract
    * @param amount the amount in ETH to create the subcontract for
    * @param sizeDiscCut is level below which the taker pays a double closeing fee r
    * @param startDay is the first day of the initial week used to get the starting price
    * @param lastOracleSettleTime makes sure takes do not happen in settlement period
    * @return subkID the id of the newly created subcontract
	*/
	 function take(address taker, uint amount, uint sizeDiscCut, uint8 startDay, uint lastOracleSettleTime, bool takerLong)
        public
        payable
        onlyAdmin
        returns (bytes32 subkID)
    {
        require(amount * 1 finney >= minRM, "must be greater than book min");
        require(lastOracleSettleTime < lastBookSettleTime, "Cannot do during settle period");
        Subcontract memory order;
        order.reqMargin = amount * 1 finney;
        order.takerMargin = msg.value;
        order.taker = taker;
        order.isActive = true;
        order.startDay = startDay;
        if (!takerLong) order.LPSide = true;
        if (takerLong) {
            require(longTakerContracts.length < MAX_SUBCONTRACTS, "bookMaxedOut");
            subkID = keccak256(abi.encodePacked(lp, now, longTakerContracts.length));  // need to add now
            order.index = longTakerContracts.length;
            longTakerContracts.push(subkID);
            LPShortMargin = add(LPShortMargin,order.reqMargin);
            if (subzero(LPShortMargin,LPLongMargin) > LPRequiredMargin)
                LPRequiredMargin = subzero(LPShortMargin,LPLongMargin);
            } else {
            require(shortTakerContracts.length < MAX_SUBCONTRACTS, "bookMaxedOut");
            subkID = keccak256(abi.encodePacked(shortTakerContracts.length,lp, now));  // need to add now
            order.index = shortTakerContracts.length;
            shortTakerContracts.push(subkID);
            LPLongMargin = add(LPLongMargin,order.reqMargin);
             if (subzero(LPLongMargin,LPShortMargin) > LPRequiredMargin)
            LPRequiredMargin = subzero(LPLongMargin,LPShortMargin);
             }
        if (add(LPLongMargin,LPShortMargin) >= sizeDiscCut) order.takerCloseDisc = true;
        subcontracts[subkID] = order;
        return subkID;
    }


     /** Withdraw margin from the LP margin
    * @param amount the amount of margin to move
    * @param lastOracleSettleTime timestamp of the last oracle setlement time
    * @notice reverts if during the settle period
    */
    function withdrawalLP(uint amount, uint lastOracleSettleTime)
        public
        onlyAdmin
    {
        if (bookDefaulted) {
            require (LPMargin >= amount, "Cannot withdraw more than the margin");
        } else {
            require (LPMargin >= add(LPRequiredMargin,amount),"Cannot to w/d more than excess margin");
            require(lastOracleSettleTime < lastBookSettleTime, "Cannot do during settle period");
        }
        LPMargin = subzero(LPMargin,amount);
        balanceSend(amount, lp);
    }

    /** Allow a taker to withdraw margin
    * @param subkID the subcontract id
    * @param lastOracleSettleTime the block timestamp of the last oracle settle price
    * @param sender who sent this message to AssetSwap
    * @notice reverts during settle period
    */
    function withdrawalTaker(bytes32 subkID, uint amount, uint lastOracleSettleTime, address sender)
        public
        onlyAdmin
    {
        require(lastOracleSettleTime < lastBookSettleTime, "Cannot do during settle period");
        Subcontract storage k = subcontracts[subkID];
        require(k.takerMargin >= add(k.reqMargin,amount),"must have sufficient margin");
        require(sender == k.taker, "Must be taker to call this function");
        k.takerMargin = subzero(k.takerMargin,amount);
        balanceSend(amount, k.taker);
    }


    /** Utility function to find the minimum of two unsigned values
    * @notice returns the first parameter if they are equal
    */
    function min(uint a, uint b)
        internal
        pure
        returns (uint)
    {
        if (a <= b)
            return a;
        else
            return b;
    }


    function subzero(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {
        if (_b >= _a)
            return 0;
        else
            return _a - _b;
    }

    function add(uint _a, uint _b)
        internal
        pure
        returns (uint)
        {
        uint c = _a + _b;
        assert(c >= _a);
        return c;
        }

}

// File: browser/AssetSwap.sol

pragma solidity ^0.5.11;



contract AssetSwap {

    /** Sets up a new SwapMarket contract
    * The creator can administrate the contract, including transferring this contract to someone else
    * Admin functions include executing th eWeekly Returns function used at settlement, and also adjusting target and basis RatesUpdated
    * adjusting for DaylightSavings (so takers cannot take during the 4 PM hour)
    *  other changes are basically for faciilitating an efficient shut down: pausing new takers, cancelling existing contracts.
    * None of these variables can be altered once created
    */

    constructor (address priceOracle)
        public
    {
        admins[msg.sender] = true;
        feeAddress = msg.sender;
        oracle = Oracle(priceOracle);
    }

    Oracle public oracle;

    bool public _isDST;  // Daylight savings dummy, is 1 if summer
    bool public _isFreeMargin; // used in intraWeek LP RM adjustment
    int public _LongRate; // in hundredths of a %
    int public _ShortRate; // in hundredths of a %
    uint public GLOBAL_SIZE_DISC; // set by Oracle to incent Takers towards the larger LPs
    uint public GLOBAL_RM_MIN;   // avoids nuisance accounts of trivial size
    int public constant TOP_BASIS = 200; //Basis rate is capped on low and high end to prevent Oracle shenanigans
    uint public constant MIN_SETTLE_TIME = 0 hours;  // requires at least 24 hours to pass after Oracle settlement update until book settlement can occur
    uint public constant NO_TAKE_HOUR = 1;  // no takes from 4-5 PM NYC time
    uint public constant TOP_TARGET = 100;  // caps Target rate to prevent Oracle mischief
    uint public constant ASSET_ID = 1; // this contract's asset ID, used for referencing price array in Oracle contract
    uint public constant _leverageRatio = 1000; // this translates to 10x leverage
    uint public _lastWeeklyReturnsTime;
    int[8] private takerLongReturns;
    int[8] private takerShortReturns;
    mapping(address => address) public _books;  // LP eth address to book contract address
    mapping(address => uint) public _withdrawBalances;  // how ETH is ultimately withdrawn
    mapping(address => bool) public admins;  // gives user right to key functions
    address payable public feeAddress;   // address for oracle fees PAYABLE!!
    address payable constant constant BURN_ADDRESS = address(0xdead);  // address payable


    event subkTracker(
        address indexed e_lp,
        address indexed e_taker,
        bytes32 e_subkID,
        bool e_open);
    event BurnHist(
        address e_lp,
        bytes32 e_subkID,
        address e_sender,
        uint e_time);
    event RatesUpdated(
        uint e_target,
        int e_basis);
    event LPNewBook(
        address e_lp,
        address e_lpBook);
    event SizeDiscUpdated(
        uint e_minLPGrossForDisc);


    modifier onlyAdmin()
    {
        require(admins[msg.sender], "admin only");
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

    /* hour of day is used for cutting off when takers can take, when LPs can withdraw.
    Time is based on New York City, USA ET, which has daylight savings, so this is needed
    */
     function adjDST(bool _isDaylightSav)
        public
        onlyAdmin
    {
       _isDST = _isDaylightSav;
    }

     /* This parameter puts a floor on the size of subcontracts, and can be used
     to prevent new takes by setting it at absurdly high levels
    */
     function adjRMMin(uint _RMMin)
        public
        onlyAdmin
    {
       GLOBAL_RM_MIN = _RMMin;
    }

       /* this prevents edge cases where an LP might not have enough RM to cover
       its liabilities. It should only be invoked when there is a price change
       implying PNLs greater than the RM intraweek, and should be reset to false at
       the subsequent settlement update
    */
     function adjisFreeMargin(bool _freeMargin)
        public
        onlyAdmin
    {
       _isFreeMargin = _freeMargin;
    }

     /** Allow the LP to change the minimum take size in their book
    * @param _min the minimum take size in ETH for the book
    */
    function adjustMinRM(uint _min)
        public
    {
        require (_books[msg.sender] != address(0), "User must have a book");
        require (_min > GLOBAL_RM_MIN);
        Book b = Book(_books[msg.sender]);
        b.adjustMinRM(_min);
    }

    /* the Oracle/admin may cancel all outstanding contracts, say if the contract was being deprecated.
    Such a cancel generates no fees, and just terminates the subcontracts at the next settlement
    */
    function adminCancel(address _lp, bytes32 subkID)
        public
        onlyAdmin
    {
        Book b = Book(_books[_lp]);
        b.adminCancel(subkID);
    }

       /* the Oracle/admin may cancel all outstanding contracts, say if the contract was being deprecated.
    Such a cancel generates no fees, and just terminates the subcontracts at the next settlement
    */
    function adminKill(address _lp)
        public
        onlyAdmin
    {
        Book b = Book(_books[_lp]);
        b.adminStop();
    }

      /** Credit a users balance with the message value
    * @param recipient the user to get balance
    * @dev used by the Book when it needs to give players value
    */
    function balanceTransfer(address recipient)
        public
        payable
    {
        _withdrawBalances[recipient] = add(_withdrawBalances[recipient],msg.value);
    }

    /** Change the address that can withdraw the collected fees
    * @param newAddress the new address to change to
    */
    function changeFeeAddress(address payable newAddress)
        public
        onlyAdmin
    {
        feeAddress = newAddress;
    }

    /** Allow the LP to create a new book
     * @param _min is the minimum take size in ETH
     * @return newBook the address of the lp book
    */
        function createBook(uint _min)
        public
        payable
        returns (address newBook)
    {
        require (_books[msg.sender] == address(0), "User must not have a preexisting book");
        require (msg.value >= _min * 2 finney, "Must prep for 2-sided book");
        _books[msg.sender] = address(new Book(msg.sender, address(this), _min));
        Book b = Book(_books[msg.sender]);
        b.fundLPMargin.value(msg.value)();
        emit LPNewBook(msg.sender, _books[msg.sender]);
        return _books[msg.sender];
    }

        /**
    * @param _lp the lp who owns the book
    * @return book the address of the lp book
    * @return lpMargin the lp's current margin
    * @return totalLong the total RM of all long contracts the LP is engaged in
    * @return totalShort the total RM of all short contracts the LP is engaged in
    * @return lpRM the margin required for the LP
    * @return numLongTakerKs the number of taker long subcontracts that the lp has in their book
    * @return numShortTakerKs the number of taker short subcontracts that the lp has in their book
    * @return bookMinimum the minimum size in wei to make a subcontract with this book
    * @return bookDefaulted if the book is defaulted
    * @return settle1done to tell LP they can now run settlement on their shorts
    */
    function getBookData(address _lp)
        public
        view
        returns (address _book,
            uint _lpMargin,
            uint _totalLpLong,
            uint _totalLpShort,
            uint _lpRM,
            uint _bookMinimum,
            uint _lastBookSettleTime,
            uint _settleNum,
            bool _bookDefaulted
            )
    {
            _book = _books[_lp];
            Book b = Book(_book);
            _lpMargin = b.LPMargin();
            _totalLpLong = b.LPLongMargin();
            _totalLpShort = b.LPShortMargin();
            _lpRM = b.LPRequiredMargin();
            _bookMinimum = b.minRM();
            _lastBookSettleTime = b.lastBookSettleTime();
            _settleNum = b.settleNum();
            _bookDefaulted = b.bookDefaulted();
    }

    /** Function to easily get specific take information about a subcontract
    * @param _lp the address of the lp with the subcontract
    * @param subkID the id of the subcontract
    * @return takerMargin the taker's margin
    * @return reqMargin the required margin of the subcontract
    * @return startDay the day of the week the contract was started on
    * @return lpSide the LP's side for the contract
    * @return takerCloseDiscount if the takers close fee will be lowered
    */


    function getSubcontractData(address _lp, bytes32 subkID)
        public
        view
        returns (
            uint _takerMargin,
            uint _reqMargin,
            bool _lpSide,
            bool _isCancelled,
            bool _isActive,
            uint8 _startDay)
    {
        address book = _books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (_takerMargin, _reqMargin, _lpSide, _isCancelled, _isActive, _startDay) = b.getSubkData(subkID);
        }
    }

      /** Function to get specific status information about a subcontract
    * @param _lp the address of the lp with the subcontract
    * @param subkID the id of the subcontract
    * @return isCancelled the status of if the subcontract is cancelled
    * @return takerBurned the status of if the subcontract is burned by taker
    * @return lpBurned the status of if the subcontract is burned by LP
    * @return takerDefaulted the status of if the taker Defaulted, and so the contract is dead and the taker should redeem it to get whatever marginis remaiing
    * @return isActive if the subcontract is redeemable or is involved in settlement
    */

    function getSubcontractStatus(address _lp, bytes32 subkID)
        public
        view
        returns (
            bool _closeDisc,
            bool _takerBurned,
            bool _lpBurned,
            bool _takerDefaulted)
    {
        address book = _books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (_closeDisc, _takerBurned, _lpBurned, _takerDefaulted) = b.getSubkDetail(subkID);
        }
    }

     function getBookBalance(address _lp)
        public
        view
        returns (
            uint playerMargin,
            uint bookETH
            )
    {
        address book = _books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (playerMargin, bookETH) = b.MarginCheck();
        }
    }



    /** Function to get specific status information about a subcontract


    function getSubcontractStatus(address _lp, bytes32 subkID)
        public
        view
        returns (
            bool isCancelled,
            bool takerBurned,
            bool lpBurned,
            bool takerDefaulted,
            bool isActive)
    {
        address book = _books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (isCancelled, takerBurned, lpBurned, takerDefaulted, isActive) = b.getSubkStatus(subkID);
        }
    }
    */

     /** Adds value to the lp's margin for their whole book
    * @param _lp the address of the lp to add margin to
    */
    function lpFund(address _lp)
        public
        payable
    {
        require(msg.sender == _lp);
        require(_books[_lp] != address(0));
        Book b = Book(_books[_lp]);
        b.fundLPMargin.value(msg.value)();
    }

    /** Burn a specific subcontract at a cost
    * @param _lp the address of the LP with the subcontract
    * @param subkID the id of the subcontract to burn
    */
    function burn(address _lp, bytes32 subkID)
        public
        payable
    {
        Book b = Book(_books[_lp]);
        uint fee = b.bookBurn(subkID, msg.sender, msg.value);
        if (msg.value > fee) {
            BURN_ADDRESS.transfer(fee);
            _withdrawBalances[msg.sender] = add(_withdrawBalances[msg.sender],msg.value - fee);
            emit BurnHist(_lp, subkID, msg.sender, now);
         }
    }

    /** Sets the contract to terminate at the end of the week
    * @param _lp the address of the lp with the subcontract
    * @param subkID the id of the subcontract to cancel
    */
    function cancel(address _lp, bytes32 subkID)
        public
        payable
    {
        Book b = Book(_books[_lp]);
        uint lastSettleTime = oracle.getLastSettleTime(ASSET_ID);
        b.bookCancel.value(msg.value)(lastSettleTime, subkID, msg.sender);
    }
    /** sets the LP book into default after 9 days of no Oracle settlement price
    * @param _lp the address of the lp with the subcontract
    */
    function inactiveOracle(address _lp)
        public
    {
        require(_books[_lp] != address(0));
        Book b = Book(_books[_lp]);
        b.inactiveOracle();
    }
    /** sets the LP book into default if  of no Oracle settlement price
    * @param _lp the address of the lp with the subcontract
    */
     function inactiveLP(address _lp, bytes32 subkID)
        public
    {
        require(_books[_lp] != address(0));
        Book b = Book(_books[_lp]);
        uint lastSettleTime = oracle.getLastSettleTime(ASSET_ID);
        b.inactiveLP(lastSettleTime, subkID);
    }
    /** Refund the balances and remove from storage a subcontract that has been defaulted, cancelled,
    * burned, or expired.
    * @param _lp is the AssetSwap contracts identifier of the LP's book
    * @param subkID the id of the subcontract with the LP's book contract
    */

    function redeem(address _lp, bytes32 subkID)
        public
    {
        require(_books[_lp] != address(0));
        Book b = Book(_books[_lp]);
        b.redeemSubcontract(subkID);
        emit subkTracker(_lp, msg.sender, subkID, false);
    }

    /** Remove administrator priviledges from a user
    * @param toRemove the address to demote
    * @notice you may not remove yourself
    */
    function removeAdmin(address toRemove)
        public
        onlyAdmin
    {
        require(toRemove != msg.sender, "You may not remove yourself as an admin.");
        admins[toRemove] = false;
    }

      function setSizeDiscCut(uint sizeDiscCut)
        public
        onlyAdmin
    {
        // sets the cutoff that determines takers pay 2x to close
        GLOBAL_SIZE_DISC = sizeDiscCut * 1 finney;
        emit SizeDiscUpdated(sizeDiscCut);
    }

     /** Adjust the Long and Short rates for all contracts
    * @param target the new target rate in hundredths of a percent
    * @param basis the new basis rate in hundredths of a percent
    * @dev the "long rate" is target - basis, the "short rate" is target + basis
    * @dev the new rates won't go into effect until the following week after WeeklyReturns is called
    */

    function setRates(uint target, int basis)
        public
        onlyAdmin
    {
        // target between 0 and 1 % per week
        // basis between -2 and 2 % per week
        // not allowed on Settlement Day, which is tthe 24 hours from settlement price update to the next price update
        require(target <= TOP_TARGET, "Target must be between 0 and 1%");
        require(-TOP_BASIS <= basis && basis <= TOP_BASIS, "Basis must be between -2 and 2%");
        require(!oracle.isSettleDay(ASSET_ID));
        _LongRate = int(target) + basis;
        _ShortRate = int(target) - basis;
        emit RatesUpdated(target, basis);
    }

    /** Settle subcontracts for this lp
    * @param _lp the lp to settle
    * must be done twice. first with the bool set to true (long takers), then with the bool set to false (short takers)
    */

    function settle(address _lp, bool _settleLong, uint _topLoop)
        public
    {
        require(_books[_lp] != address(0));
        Book b = Book(_books[_lp]);
        // can only be run on settlement day, if missed all subcontracts can redeem
         require(oracle.isSettleDay(ASSET_ID));
        uint _lastSettle = oracle.getLastSettleTime(ASSET_ID);
        // must use WeeklyReturns that used recent Settlement prices
        require(_lastWeeklyReturnsTime > _lastSettle);
         // must wait at least 24 hours from the Oracle update
        require (now > _lastSettle + MIN_SETTLE_TIME, "Give players more time");
        if (_settleLong) b.settleLong(takerLongReturns, _topLoop); else b.settleShort(takerShortReturns, _topLoop);
    }

    /** Adds value to the taker's margin
    * @param _lp the address of the lp with the subcontract
    * @param subkID the id of the subcontract to add margin to
    */
    function takerFund(address _lp, bytes32 subkID)
        public
        payable
    {
        require(_books[_lp] != address(0));
        Book b = Book(_books[_lp]);
        b.fundTakerMargin.value(msg.value)(subkID);
    }

    /** Take a new subcontract with an LP
    * @param _lp the LP to take from
    * @param amount the amount IN finney to set the RM of the subcontract
    */
    function take(address _lp, uint amount, bool isTakerLong)
        public
        payable
    {
        require(msg.value >= amount * (1 finney), "Insuffient ETH for this RM"); // allow only whole number amounts
        require(hourOfDay() != NO_TAKE_HOUR, "Cannot take during 4 PM ET hour");  // cannot take from 4-5 PM ET   16
        require(amount > GLOBAL_RM_MIN);
        Book book = Book(_books[_lp]);
        uint lpLong = book.LPLongMargin();
        uint lpShort = book.LPShortMargin();
        uint freeMargin = 0;
        uint8 startDay = oracle.getStartDay(ASSET_ID);
        uint lastOracleSettleTime = oracle.getLastSettleTime(ASSET_ID);
        if (_isFreeMargin) {
        if (isTakerLong) freeMargin = subzero(lpLong,lpShort);
        else freeMargin = subzero(lpShort,lpLong);
        }
        require(amount * 1 finney <= subzero(book.LPMargin(),book.LPRequiredMargin())/2 + freeMargin, "RM to large for this LP on this side");
        bytes32 newsubkID = book.take.value(msg.value)(msg.sender, amount, GLOBAL_SIZE_DISC, startDay, lastOracleSettleTime, isTakerLong);
        emit subkTracker(_lp, msg.sender, newsubkID,true);
    }


//    Upon the Oracle Settlement Update, the weekly returns are calculated so that LPs can settle their _books
//    There is a minimum amount of time between the Oracle Contract update and the calculation of the Weekly Returns to give players
//    time to burn their PNLs if the Oracle applies fraudulent prices
    function weeklyReturns()
        public
        onlyAdmin
    {
        // only compute returns after settle price posted
       require(oracle.isSettleDay(ASSET_ID));

        uint[8] memory assetPrice  = oracle.getPrices(ASSET_ID);
        uint[8] memory ethPrice = oracle.getPrices(0);

        for (uint i = 0; i < 7; i++)
        {
            if (assetPrice[i] == 0 || ethPrice[i] == 0) continue;
            int assetReturn = int((assetPrice[7] * (1 finney)) / assetPrice[i] ) - 1 finney;
            takerLongReturns[i] = assetReturn - ((1 finney) * int(_LongRate))/1e4;
            takerShortReturns[i] = (-1 * assetReturn) - ((1 finney) * int(_ShortRate))/1e4;
            takerLongReturns[i] = (takerLongReturns[i] * int(_leverageRatio * ethPrice[i]))/int(ethPrice[7] * 100);
            takerShortReturns[i] = (takerShortReturns[i] * int(_leverageRatio * ethPrice[i]))/int(ethPrice[7] * 100);
        }
         _lastWeeklyReturnsTime = now;

    }



    /** Moves value out of the lp margin into the withdraw balance
    * @param amount the amount to move in wei
    */
    function withdrawalLP(uint amount)
        public
    {
        require(_books[msg.sender] != address(0));
        Book b = Book(_books[msg.sender]);
        uint lastOracleSettleTime= oracle.getLastSettleTime(ASSET_ID);
        // Will revert if during settle period, oraclesettle after last Book settle time
        b.withdrawalLP(amount, lastOracleSettleTime);
    }

    /** Moves value out of the taker margin into the withdraw balance
    * @param amount the amount to move in wei
    * @param _lp the lp with the subcontract to move balance from the taker margin
    * @param subkID the id of the subcontract
    */
    function withdrawalTaker(uint amount, address _lp, bytes32 subkID)
        public
    {
        require(_books[_lp] != address(0));
        Book b = Book(_books[_lp]);
        uint lastOracleSettleTime = oracle.getLastSettleTime(ASSET_ID);
        // will revert if during settle period
        b.withdrawalTaker(subkID, amount, lastOracleSettleTime, msg.sender);
    }

    /** Sends the owed balance to a user stored on this contract to an external address
    */
    function withdrawBalance()
        public
    {
        uint amount = _withdrawBalances[msg.sender];
        _withdrawBalances[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    /** we do not want users taking in the 16 hour (4 PM) because there is a slight delay in between when
    *  the price is recorded and poosted, so we do not want takers to exploit this option
    *  @return hour1 of NYC time
     */
    function hourOfDay()
        public
        view
        returns(uint hour1)
    {
        hour1= (now  % 86400) / 3600 - 5;
        if (_isDST) hour1=hour1 + 1;
    }
    /**
     * truncated subtraction, where result <0 is set to 0
    */

    function subzero(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {
        if (_b >= _a) {
        return 0;
    }
        return _a - _b;
    }
    /**
    * adding and protecting against overflow errors
    */

    function add(uint _a, uint _b)
        internal
        pure
        returns (uint)
    {
        uint c = _a + _b;
        assert(c >= _a);
        return c;
    }

}
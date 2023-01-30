pragma solidity ^0.5.11;

import "./Book.sol";
import "./Oracle.sol";

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
    uint public constant NO_TAKE_HOUR = 1600;  // 16  no takes from 4-5 PM NYC time
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
 //       require(hourOfDay() != NO_TAKE_HOUR, "Cannot take during 4 PM ET hour");  // cannot take from 4-5 PM ET   16
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
        emit subkTracker(_lp, msg.sender, newsubkID, true);
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

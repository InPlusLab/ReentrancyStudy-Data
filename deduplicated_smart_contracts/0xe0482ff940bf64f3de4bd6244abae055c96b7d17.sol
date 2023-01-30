pragma solidity 0.6.3;

import "./Book.sol";
import "./Oracle.sol";

/**
MIT License
Copyright © 2020 Eric G. Falkenstein

Permission is hereby granted,  free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge,
publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
 OR OTHER DEALINGS IN THE SOFTWARE.
*/

contract AssetSwap {

    constructor (address priceOracle, int _levRatio)
        public {
            administrators[msg.sender] = true;
            feeAddress = msg.sender;
            oracle = Oracle(priceOracle);
            levRatio = _levRatio;
        }

    Oracle public oracle;
    int[5][2] public assetReturns; /// these are pushed by the oracle each week
    int public levRatio;
    uint public lastOracleSettleTime; /// updates at time of oracle settlement.
    /// Used a lot so this is written to the contract
    mapping(address => address) public books;  /// LP eth address to book contract address
    mapping(address => uint) public assetSwapBalance;  /// how ETH is ultimately withdrawn
    mapping(address => bool) public administrators;  /// gives user right to key functions
    address payable public feeAddress;   /// address for oracle fees

    event SubkTracker(
        address indexed eLP,
        address indexed eTaker,
        bytes32 eSubkID,
        bool eisOpen);

    event BurnHist(
        address eLP,
        bytes32 eSubkID,
        address eBurner,
        uint eTime);

    event LPNewBook(
        address indexed eLP,
        address eLPBook);

    event RatesUpdated(
        address indexed eLP,
        uint8 closefee,
        int16 longFundingRate,
        int16 shortFundingRate
        );

    modifier onlyAdmin() {
        require(administrators[msg.sender], "admin only");
        _;
    }

    function removeAdmin(address toRemove)
        external
        onlyAdmin
    {
        require(toRemove != msg.sender, "You may not remove yourself as an admin.");
        administrators[toRemove] = false;
    }

    function addAdmin(address newAdmin)
        external
        onlyAdmin
    {
        administrators[newAdmin] = true;
    }

    function adjustMinRM(uint16 _min)
        external
    {
        require(books[msg.sender] != address(0), "User must have a book");
        require(_min >= 1);
        Book b = Book(books[msg.sender]);
        b.adjustMinRMBook(_min);
    }

    /** data are input in basis points as a percent of national
    * thus 10 is 0.1% of notional, which when applied to the crypto
    * with 2.5 leverage, generates a 0.25% of RM charge. funding rates
    * can be negative, which implies the taker receives a payment.
    * if you change the fees so they can be greater than 2.5% of RM,
    * say X, you must adjustn the Oracle contract to have a maximum value of
    * 1 - X, so that player RM can cover every conceivable scenario
    */
    function updateFees(uint newClose, int frLong, int frShort)
        external
    {
        require(books[msg.sender] != address(0), "User must have a book");
        /// data are input as basis points of notional, adjusted to bps of RM to simplify calculations
        /// thus for the spx, the leverage ratio is 1000, and so dividing it by 1e2 gives 10
        /// Thus for the spx, a long rate of 0.21% per week, applied to the notional,
        /// is 2.1% per week applied to the RM
        int longRate = frLong * levRatio / 1e2;
        int shortRate = frShort * levRatio / 1e2;
        uint closefee = newClose * uint(levRatio) / 1e2;
        /// fees are capped to avoid predatory pricing that would potentially besmirch OracleSwap's reputation
        require(closefee <= 250);
        require(longRate <= 250 && longRate >= -250);
        require(shortRate <= 250 && shortRate >= -250);
        Book b = Book(books[msg.sender]);
        b.updateFeesBook(uint8(closefee), int16(longRate), int16(shortRate));
        emit RatesUpdated(msg.sender, uint8(closefee), int16(longRate), int16(shortRate));
    }

    function changeFeeAddress(address payable newAddress)
        external
        onlyAdmin
    {
        feeAddress = newAddress;
    }
    /** this is where money is sent from the Book contract to a player's account
    * the player can then withdraw this to their personal address
    */

    function balanceInput(address recipient)
            external
            payable
    {
        assetSwapBalance[recipient] += msg.value;
    }

    /** fees are in basis points of national, as in the case when updating the fees
    * minimum RM is in Szabo, so 4 would imply a minimum RM of 4 Szabo
    */
    function createBook(uint16 _min, uint _closefee, int frLong, int frShort)
        external
        payable
        returns (address newBook)
    {
        require(books[msg.sender] == address(0), "User must not have a preexisting book");
        require(msg.value >= uint(_min) * 10 szabo, "Must prep for book");
        require(_min >= 1);
        int16 longRate = int16(frLong * levRatio / 1e2);
        int16 shortRate = int16(frShort * levRatio / 1e2);
        uint8 closefee = uint8(_closefee * uint(levRatio) / 1e2);
        require(longRate <= 250 && longRate >= -250);
        require(shortRate <= 250 && shortRate >= -250);
        require(closefee <= 250);
        books[msg.sender] = address(new Book(msg.sender, address(this), _min, closefee, longRate, shortRate));
        Book b = Book(books[msg.sender]);
        b.fundLPBook.value(msg.value)();
        emit LPNewBook(msg.sender, books[msg.sender]);
        return books[msg.sender];
    }

    function fundLP(address _lp)
        external
        payable
    {
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.fundLPBook.value(msg.value)();
    }

    function fundTaker(address _lp, bytes32 subkID)
        external
        payable
        {
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.fundTakerBook.value(msg.value)(subkID);
    }

    function burnTaker(address _lp, bytes32 subkID)
        external
        payable
    {
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        uint refund = b.burnTakerBook(subkID, msg.sender, msg.value);
        emit BurnHist(_lp, subkID, msg.sender, now);
        assetSwapBalance[msg.sender] += refund;
    }

    function burnLP()
        external
        payable
    {
        require(books[msg.sender] != address(0));
        Book b = Book(books[msg.sender]);
        uint refund = b.burnLPBook(msg.value);
        bytes32 abcnull;
        emit BurnHist(msg.sender, abcnull, msg.sender, now);
        assetSwapBalance[msg.sender] += refund;
    }

    function cancel(address _lp, bytes32 subkID, bool closeNow)
        external
        payable
    {
        require(hourOfDay() != 16, "Cannot cancel during 4 PM ET hour");
        Book b = Book(books[_lp]);
        uint8 priceDay = oracle.getStartDay();
        uint8 endDay = 5;
        if (closeNow)
            endDay = priceDay;
        b.cancelBook.value(msg.value)(lastOracleSettleTime, subkID, msg.sender, endDay);
    }

    function closeBook(address _lp)
        external
        payable
    {
        require(msg.sender == _lp);
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.closeBookBook.value(msg.value)();
    }

    function redeem(address _lp, bytes32 subkID)
        external
    {
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.redeemBook(subkID, msg.sender);
        emit SubkTracker(_lp, msg.sender, subkID, false);
    }
      /** once started, this process requires a total of at least 4 separate executions.
      * Each execution is limited to processing 200 subcontracts to avoid gas limits, so if there
      * are more than 200 accounts in any step they will have to be executed multiple times
      * eg, 555 new accounts would require 3 executions of that step
      */

    function settleParts(address _lp)
        external
        returns (bool isComplete)
    {
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        uint lastBookSettleTime = b.lastBookSettleTime();
        require(now > (lastOracleSettleTime + 24 hours));
        require(lastOracleSettleTime > lastBookSettleTime, "one settle per week");
        uint settleNumb = b.settleNum();
        if (settleNumb < 1e4) {
            b.settleExpiring(assetReturns[1]);
        } else if (settleNumb < 2e4) {
            b.settleRolling(assetReturns[0][0]);
        } else if (settleNumb < 3e4) {
            b.settleNew(assetReturns[0]);
        } else if (settleNumb == 3e4) {
            b.settleFinal();
            isComplete = true;
        }
    }

    function settleBatch(address _lp)
        external
    {
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        uint lastBookSettleTime = b.lastBookSettleTime();
        require(now > (lastOracleSettleTime + 24 hours));
        require(lastOracleSettleTime > lastBookSettleTime, "one settle per week");
        /// the 5x1 vector of returns in units of szabo, where 0.6 is a +60% of RM payoff,
        /// -0.6 is a -60% of RM payoff. The refer to initial price days to settlement day
        b.settleExpiring(assetReturns[1]);
        /// this is the settle to settle return
        b.settleRolling(assetReturns[0][0]);
        /// this is the return from the last settlement day to the price day
        /// for regular closes, the price day == 5, so it is a settlement to settlement return
        b.settleNew(assetReturns[0]);
        b.settleFinal();
    }

    function take(address _lp, uint rm, bool isTakerLong)
        external
        payable
        returns (bytes32 newsubkID)
    {
        require(rm < 3, "above max size"); // This is to make this contract economically trivial
        /// a real contract would allow positions much greater than 2 szabos
        rm = rm * 1 szabo;
        require(msg.value >= 3 * rm / 2, "Insuffient ETH for your RM");
        require(hourOfDay() != 16, "Cannot take during 4 PM ET hour");

        uint takerLong;
        if (isTakerLong)
            takerLong = 1;
        else
            takerLong = 0;
        /// starting price is taken from the oracle contract based on what the next price day is
        uint8 priceDay = oracle.getStartDay();
        Book book = Book(books[_lp]);
        newsubkID = book.takeBook.value(msg.value)(msg.sender, rm, lastOracleSettleTime, priceDay, takerLong);
        emit SubkTracker(_lp, msg.sender, newsubkID, true);
    }

    /** withdraw amounts are in 1/1000 of the unit of denomination
    * Thus, 1234 is 1.234 Szabo
    */
    function withdrawLP(uint amount)
        external
    {
        require(amount > 0);
        require(books[msg.sender] != address(0));
        Book b = Book(books[msg.sender]);
        amount = 1e9 * amount;
        b.withdrawLPBook(amount, lastOracleSettleTime);
    }

    function withdrawTaker(uint amount, address _lp, bytes32 subkID)
        external
    {
        require(amount > 0);
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        amount = 1e9 * amount;
        b.withdrawTakerBook(subkID, amount, lastOracleSettleTime, msg.sender);
    }
    /// one can withdraw from one's assetSwap balance at any time. It can only send the entire amount

    function withdrawFromAssetSwap()
        external
    {
        uint amount = assetSwapBalance[msg.sender];
        require(amount > 0);
        assetSwapBalance[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function inactiveOracle(address _lp)
        external
    {
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.inactiveOracleBook();
    }

    function inactiveLP(address _lp, bytes32 subkID)
        external
    {
        require(books[_lp] != address(0));
        Book b = Book(books[_lp]);
        b.inactiveLPBook(subkID, msg.sender, lastOracleSettleTime);
    }

    function getBookData(address _lp)
        external
        view
        returns (address book,
            // balances in wei
            uint lpMargin,
            uint totalLpLong,
            uint totalLpShort,
            uint lpRM,
            /// in Szabo
            uint bookMinimum,
            /// in basis points as a percent of RM
            /// to convert to notional, we multiply by the leverage ratio
            int16 longFundingRate,
            int16 shortFundingRate,
            uint8 lpCloseFee,
            /** 0 is fine, 1 means book cancels at next settlement
            * 2 means LP burned (which cancels the book at next settlement)
            * 3 book is inactive, no more settling or new positions
            */
            uint8 bookStatus
            )
    {
        book = books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            lpMargin = b.margin(0);
            totalLpLong = b.margin(1);
            totalLpShort = b.margin(2);
            lpRM = b.margin(3);
            bookMinimum = b.lpMinTakeRM();
            longFundingRate = b.fundingRates(1);
            shortFundingRate = b.fundingRates(0);
            lpCloseFee = b.bookCloseFee();
            bookStatus = b.bookStatus();
        }
    }

    function getSubkData1(address _lp, bytes32 subkID)
        external
        view
        returns (
            address taker,
            /// in wei
            uint takerMargin,
            uint reqMargin
            )
    {
        address book = books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (taker, takerMargin, reqMargin) = b.getSubkData1Book(subkID);
        }
    }

    function getSubkData2(address _lp, bytes32 subkID)
        external
        view
        returns (
          /** 0 new, 1 active and rolled over, 2 taker cancelled, 3 LP cancelled,
          * 4 intraweek cancelled, 5 taker burned, 6 taker default/redeemable, 7 inactive/redeemable
          */
            uint8 subkStatus,
          /// for new and expiring subcontracts, either the start or end price that week
            uint8 priceDay,
          /** the LP's closing fee, in basis points as a percent of the RM. The total closing fee
          * is this plus 2.5% of RM, the oracle's fee
          */
            uint8 closeFee,
          /// the funding rate paid by the taker, which may be negative
            int16 fundingRate,
          /// true for taker is long (and thus LP is short)
            bool takerSide
            )
    {
        address book = books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (subkStatus, priceDay, closeFee, fundingRate, takerSide)
                = b.getSubkData2Book(subkID);
        }
    }

    function getSettleInfo(address _lp)
        external
        view
        returns (
          /// total number of taker subcontracts, including new, rolled-over, cancelled, and inactive subcontracts
            uint totalLength,
          /// taker subcontracts that are expiring at next settlement
            uint expiringLength,
          /// taker subcontracts that have not yet settled. Such positions cannot be cancelled. The next week,
          /// they will be 'active', and cancelable.
            uint newLength,
          /// time of last book settlement, in seconds from 1970, Greenwich Mean Time
            uint lastBookSettleUTC,
          /// this is used for assessing the progress of a settlement when it is too large to be
          /// executed in batch.
            uint settleNumber,
          /// amount of ETH in the LP book
            uint bookBalance,
          /// an LP can close they book en masse, which would push the maturity of the book to 28 days after
          /// the close is instantiated. Takers should take note. A taker does not pay a cancel fee when
          /// the LP cancels their book, but they must then wait until the final settlement
            uint bookMaturityUTC
            )
    {
        address book = books[_lp];
        if (book != address(0)) {
            Book b = Book(book);
            (totalLength, expiringLength, newLength, lastBookSettleUTC, settleNumber,
                bookBalance, bookMaturityUTC) = b.getSettleInfoBook();
        }
    }

    /**
    * This gives the raw asset returns for all potential start and end dates: 5 different returns
    * for new positions (price day to settlement day), and 5 for expiring positions (last settlement to price day)
    * these are posted by the Oracle at the settlemnet price update.
    * They are in % return * Leverage Ratio times 1 Szabo,
    * this allows the books to simply apply these numbers to the RM of the various subcontracts to generate the
    * weekly PNL. They are capped at +/- 0.975e12 (the unit of account in this contract, szabo),
    * so that the extreme case of a maximum funding rate, the liability
    * is never greater than 1 Szabo. This effectively caps player liability at their RM
    */
    function updateReturns(int[5] memory assetRetNew, int[5] memory assetRetExp)
            public
        {
        require(msg.sender == address(oracle));
        assetReturns[0] = assetRetNew;
        assetReturns[1] = assetRetExp;
        lastOracleSettleTime = now;
    }

    function hourOfDay()
        public
        view
        returns(uint hour1)
    {
        uint nowTemp = now;
    /**
    * 2020 Summer, 1583668800 = March 8 2020 through 1604232000 = November 1 2020
    * 2021 Summer, 1615705200 = March 14 2021 through 1636264800 = November 7 2021
    * 2022 summer, 1647154800 = March 13 2022 through 1667714400 = November 6 2022
    * summer is Daylight Savings Time in the US, where the hour is GMT - 5 in New York City
    * winter is Standard Time in the US, where the hour is GMT - 4 in New York City
    * No takes from 4-5 PM NYC time, so hour == 16 is the exclusion time
    * hour1 takes the number of seconds in the day at this time (nowTemp % 86400),
    * and divideds by the number of seconds in an hour 3600
    */
        hour1 = (nowTemp % 86400) / 3600 - 5;
        if ((nowTemp > 1583668800 && nowTemp < 1604232000) || (nowTemp > 1615705200 && nowTemp < 1636264800) ||
            (nowTemp > 1647154800 && nowTemp < 1667714400))
            hour1 = hour1 + 1;
    }

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


}

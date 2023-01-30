pragma solidity 0.6.3;

import "./AssetSwap.sol";

/**
MIT License
Copyright © 2020 Eric G. Falkenstein

Permission is hereby granted, free of charge, to any person
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

contract Oracle {

    constructor (uint ethPrice, uint spxPrice, uint btcPrice) public {
        admins[msg.sender] = true;
        prices[0][5] = ethPrice;
        prices[1][5] = spxPrice;
        prices[2][5] = btcPrice;
        lastUpdateTime = now;
        lastSettleTime = now - 2 days;
        currentDay = 5;
        levRatio[0] = 250;  // ETH contract 2.5 leverage
        levRatio[1] = 1000; /// SPX contract 10.0 leverage
        levRatio[2] = 250;  // BTC contract 2.5 leverage
    }

    address[3] public assetSwaps;
    uint[6][3] private prices;
    uint public lastUpdateTime;
    uint public lastSettleTime;
    int[3] public levRatio;
    uint8 public currentDay;
    bool public nextUpdateSettle;
    mapping(address => bool) public admins;
    mapping(address => bool) public readers;

    event PriceUpdated(
        uint ethPrice,
        uint spxPrice,
        uint btcPrice,
        uint eUTCTime,
        uint eDayNumber,
        bool eisCorrection
    );

    event AssetSwapContractsChange(
        address ethSwapContract,
        address spxSwapContract,
        address btcSwapContract
    );

    event ChangeReaderStatus(
        address reader,
        bool onOrOff
    );

    modifier onlyAdmin() {
        require(admins[msg.sender]);
        _;
    }
    /** Grant write priviledges to a user,
    * mainly intended for when the admin wants to switch accounts, ie, paired with a removal
    */

    function addAdmin(address newAdmin)
        external
        onlyAdmin
    {
        admins[newAdmin] = true;
    }

    function removeAdmin(address toRemove)
            external
            onlyAdmin
    {
        require(toRemove != msg.sender);
        admins[toRemove] = false;
    }
    /** Grant priviledges to a user accessing price data on the blockchain
    * @param newReader the address. Any reader is thus approved by the oracle/admin
    * useful for new contracts that  use this oracle, in that the oracle would not
    * need to create a new oracle contract for ETH prices
    */

    function addReaders(address newReader)
        external
        onlyAdmin
    {
        readers[newReader] = true;
        emit ChangeReaderStatus(newReader, true);
    }

    function removeReaders(address oldReader)
        external
        onlyAdmin
    {
        readers[oldReader] = false;
        emit ChangeReaderStatus(oldReader, false);
    }
    /** this can only be done once, so this oracle is solely for working with
    * three AssetSwap contracts
    * assetswap 0 is the ETH, at 2.5 leverage
    * assetswap 1 is the SPX, at 10x leverage
    * assetswap 2 is the BTC, at 2.5 leverage
    *
    */

    function changeAssetSwaps(address newAS0, address newAS1, address newAS2)
        external
        onlyAdmin
    {
        require(now > lastSettleTime && now < lastSettleTime + 1 days, "only 1 day after settle");
        assetSwaps[0] = newAS0;
        assetSwaps[1] = newAS1;
        assetSwaps[2] = newAS2;
        readers[newAS0] = true;
        readers[newAS1] = true;
        readers[newAS2] = true;
        emit AssetSwapContractsChange(newAS0, newAS1, newAS2);
    }
    /** Quickly fix an erroneous price, or correct the fact that 50% movements are
    * not allowed in the standard price input
    * this must be called within 60 minutes of the initial price update occurence
    */

    function editPrice(uint _ethprice, uint _spxprice, uint _btcprice)
        external
        onlyAdmin
    {
        require(now < lastUpdateTime + 60 minutes);
        prices[0][currentDay] = _ethprice;
        prices[1][currentDay] = _spxprice;
        prices[2][currentDay] = _btcprice;
        emit PriceUpdated(_ethprice, _spxprice, _btcprice, now, currentDay, true);
    }

    function updatePrices(uint ethp, uint spxp, uint btcp, bool _newFinalDay)
        external
        onlyAdmin
    {

             /// no updates within 20 hours of last update
        require(now > lastUpdateTime + 20 hours);
            /** can't be executed if the next price should be a settlement price
            * settlement prices are special because they need to update the asset returns
            * and sent to the AssetSwap contracts
            */
        require(!nextUpdateSettle);
         /// after settlement update, at least 48 hours until new prices are posted
        require(now > lastSettleTime + 48 hours, "too soon after last settle");
          /// prevents faulty prices, as stale prices are a common source of bad prices.
        require(ethp != prices[0][currentDay] && spxp != prices[1][currentDay] && btcp != prices[2][currentDay]);
            /// extreme price movements are probably mistakes. They can be posted
          /// but only via a 'price edit' that must be done within 60 minutes of the initial update
          /// many errors generate inputs off by orders of magnitude, which imply returns of >100% or <-90%
        require((ethp * 10 < prices[0][currentDay] * 15) && (ethp * 10 > prices[0][currentDay] * 5));
        require((spxp * 10 < prices[1][currentDay] * 15) && (spxp * 10 > prices[1][currentDay] * 5));
        require((btcp * 10 < prices[2][currentDay] * 15) && (btcp * 10 > prices[2][currentDay] * 5));
        if (currentDay == 5) {
            currentDay = 1;
        } else {
            currentDay += 1;
            nextUpdateSettle = _newFinalDay;
        }
        if (currentDay == 4)
            nextUpdateSettle = true;
        updatePriceSingle(0, ethp);
        updatePriceSingle(1, spxp);
        updatePriceSingle(2, btcp);
        emit PriceUpdated(ethp, spxp, btcp, now, currentDay, false);
        lastUpdateTime = now;
    }

    function settlePrice(uint ethp, uint spxp, uint btcp)
        external
        onlyAdmin
    {
        require(nextUpdateSettle);
        require(now > lastUpdateTime + 20 hours);
        require(ethp != prices[0][currentDay] && spxp != prices[1][currentDay] && btcp != prices[2][currentDay]);
        require((ethp * 10 < prices[0][currentDay] * 15) && (ethp * 10 > prices[0][currentDay] * 5));
        require((spxp * 10 < prices[1][currentDay] * 15) && (spxp * 10 > prices[1][currentDay] * 5));
        require((btcp * 10 < prices[2][currentDay] * 15) && (btcp * 10 > prices[2][currentDay] * 5));
        currentDay = 5;
        nextUpdateSettle = false;
        updatePriceSingle(0, ethp);
        updatePriceSingle(1, spxp);
        updatePriceSingle(2, btcp);
        int[5] memory assetReturnsNew;
        int[5] memory assetReturnsExpiring;
        int cap = 975 * 1 szabo / 1000;
        for (uint j = 0; j < 3; j++) {
                  /**  asset return from start day j to settle day (ie, day 5),
                  * and also the prior settle day (day 0) to the end day.
                  * returns are normalized from 0.975 szabo to - 0.975 szabo
                  * where 0.9 szabo is a 90% of RM profit for the long taker,
                  * 0.2 szabo means a 20% of RM profit for the long taker.
                  */
            for (uint i = 0; i < 5; i++) {
                if (prices[0][i] != 0) {
                    int assetRetFwd = int(prices[j][5] * 1 szabo / prices[j][i]) - 1 szabo;
                    assetReturnsNew[i] = assetRetFwd * int(prices[0][i]) * levRatio[j] /
                        int(prices[0][5]) / 100;
                /** as funding rates are maxed out at 2.5% of RM, the return must
                * max out at 97.5% of RM so that required margins cover all
                * potential payment scenarios
                */
                    assetReturnsNew[i] = bound(assetReturnsNew[i], cap);
                }
                if (prices[0][i+1] != 0) {
                    int assetRetBack = int(prices[j][i+1] * 1 szabo / prices[j][0]) - 1 szabo;
                    assetReturnsExpiring[i] = assetRetBack * int(prices[0][0]) * levRatio[j] /
                        int(prices[0][i+1]) / 100;

                    assetReturnsExpiring[i] = bound(assetReturnsExpiring[i], cap);
                }
            }
    /// this updates the AssetSwap contract with the vector of returns,
    /// one for each day of the week
            AssetSwap asw = AssetSwap(assetSwaps[j]);
            asw.updateReturns(assetReturnsNew, assetReturnsExpiring);
        }
        lastSettleTime = now;
        emit PriceUpdated(ethp, spxp, btcp, now, currentDay, false);
        lastUpdateTime = now;
    }
    /** Return the entire current price array for a given asset
    * @param _assetID the asset id of the desired asset
    * @return _priceHist the price array in USD for the asset
    * @dev only the admin and addresses granted readership may call this function
    * While only an admin or reader can access this within the EVM
    * anyone can access these prices outside the EVM
    * eg, in javascript: OracleAddress.methods.getUsdPrices.cacheCall(0, { 'from': 'AdminAddress' }
    */

    function getUsdPrices(uint _assetID)
        public
        view
        returns (uint[6] memory _priceHist)
    {
        require(admins[msg.sender] || readers[msg.sender]);
        _priceHist = prices[_assetID];
    }

        /** Return only the latest prices
        * @param _assetID the asset id of the desired asset
        * @return _price the latest price of the given asset
        * @dev only the admin or a designated reader may call this function within the EVM
        */
    function getCurrentPrice(uint _assetID)
        public
        view
        returns (uint _price)
    {
        require(admins[msg.sender] || readers[msg.sender]);
        _price = prices[_assetID][currentDay];
    }

    /**
    * @return _startDay relevant for trades done now
    * pulls the day relevant for new AssetSwap subcontracts
    * startDay 2 means the 2 slot (ie, the third) of prices will be the initial
    * price for the subcontract. As 5 is the top slot, and rolls into slot 0
    * the next week, the next pricing day is 1 when the current day == 5
    * (this would be a weekend or Monday morning)
    */
    function getStartDay()
        public
        view
        returns (uint8 _startDay)
    {
        if (nextUpdateSettle) {
            _startDay = 5;
        } else if (currentDay == 5) {
            _startDay = 1;
        } else {
            _startDay = currentDay + 1;
        }
    }

    function updatePriceSingle(uint _assetID, uint _price)
        internal
    {
        if (currentDay == 1) {
            uint[6] memory newPrices;
            newPrices[0] = prices[_assetID][5];
            newPrices[1] = _price;
            prices[_assetID] = newPrices;
        } else {
            prices[_assetID][currentDay] = _price;
        }
    }

    function bound(int a, int b)
        internal
        pure
        returns (int)
    {
        if (a > b)
            a = b;
        if (a < -b)
            a = -b;
        return a;
    }

}

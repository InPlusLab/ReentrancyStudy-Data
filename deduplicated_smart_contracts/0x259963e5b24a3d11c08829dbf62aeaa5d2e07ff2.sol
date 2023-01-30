pragma solidity 0.5.11;

import "./IERC20.sol";
import "./WithdrawableV5.sol";
import "./UtilsV5.sol";
import "./IOtc.sol";

contract IWeth is IERC20 {
    function deposit() public payable;
    function withdraw(uint) public;
}

contract Eth2DaiReserve is Withdrawable, Utils {

    // constants
    uint constant internal INVALID_ID = uint(-1);
    uint constant internal POW_2_32 = 2 ** 32;
    uint constant internal POW_2_96 = 2 ** 96;
    uint constant internal BPS = 10000; // 10^4

    IOtc public otc;
    IWeth public wethToken;// = IWeth(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    uint public maxTakes;
    uint public maxTraverse;

    struct OfferData {
        uint payAmount;
        uint buyAmount;
        uint id;
    }

    constructor(address _otc, address _weth, address _admin, uint _maxTakes, uint _maxTraverse) 
        public Withdrawable(_admin)
    {
        require(_otc != address(0), "constructor: otc's address is missing");
        require(_weth != address(0), "constructor: weth's address is missing");

        wethToken = IWeth(_weth);
        require(getDecimals(wethToken) == MAX_DECIMALS, "constructor: wethToken's decimals is not MAX_DECIMALS");

        otc = IOtc(_otc);
        admin = _admin;
        maxTakes = _maxTakes;
        maxTraverse = _maxTraverse;
    }

    function() external payable {} // solhint-disable-line no-empty-blocks

    /**
        Returns conversion rate of given pair and srcQty, use 1 as srcQty if srcQty = 0
        Using eth amount to compute offer limit configurations
        => need to check spread is ok for token -> eth
        Last bit of the rate indicates whether to use internal inventory:
          0 - use eth2dai
          1 - use internal inventory
    */
    function getConversionRate(IERC20 src, IERC20 dest, uint srcQty, uint) public view returns(uint) {
        if (srcQty == 0) { return 0; }
        IERC20 token = src == ETH_TOKEN_ADDRESS ? dest : src;

        OfferData memory bid;
        OfferData memory ask;
        (bid, ask) = getFirstBidAndAskOrders(token);

        uint destQty;
        OfferData[] memory offers;

        if (src == ETH_TOKEN_ADDRESS) {
            (destQty, offers) = findBestOffers(dest, wethToken, srcQty, bid, ask);
        } else {
            (destQty, offers) = findBestOffers(wethToken, src, srcQty, bid, ask);
        }

        if (offers.length == 0 || destQty == 0) { return 0; } // no offer or destQty == 0, return 0 for rate

        uint rate = calcRateFromQty(srcQty, destQty, MAX_DECIMALS, MAX_DECIMALS);

        return rate;
    }

    event ContractsSet(address otc);

    function setContracts(address _otc) public onlyAdmin {
        require(_otc != address(0), "setContracts: otc's address is missing");

        otc = IOtc(_otc);

        emit ContractsSet(_otc);
    }

    event DataSet(uint maxTakes, uint maxTraverse);

    function setMaxTakesAndTraverse(uint _maxTakes, uint _maxTraverse) public onlyAdmin {
        maxTakes = _maxTakes;
        maxTraverse = _maxTraverse;
    }

    function findBestOffers(
        IERC20 dstToken,
        IERC20 srcToken,
        uint srcAmount,
        OfferData memory bid,
        OfferData memory ask
    )
        internal view
        returns(uint totalDestAmount, OfferData[] memory offers)
    {
        uint remainingSrcAmount = srcAmount;
        uint maxOrdersToTake = maxTakes;
        uint maxTraversedOrders = maxTraverse;
        uint numTakenOffer = 0;
        totalDestAmount = 0;

        offers = new OfferData[](maxTraversedOrders);

        // return earlier, we don't want to take any orders
        if (maxTraversedOrders == 0 || maxOrdersToTake == 0) {
            return (totalDestAmount, offers);
        }

        // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
        // if we don't have best offers, get them.
        if ((srcToken == wethToken && bid.id == 0) || (dstToken == wethToken && ask.id == 0)) {
            offers[0].id = otc.getBestOffer(dstToken, srcToken);
            // assuming pay amount is taker pay amount. (in otc it is used differently)
            (offers[0].buyAmount, , offers[0].payAmount, ) = otc.getOffer(offers[0].id);
        } else {
            offers[0] = srcToken == wethToken ? bid : ask;
        }

        uint thisOffer;

        OfferData memory biggestSkippedOffer = OfferData(0, 0, 0);

        for (; maxTraversedOrders > 0; --maxTraversedOrders) {
            thisOffer = numTakenOffer;

            // in case both biggestSkippedOffer & current offer have amount >= remainingSrcAmount
            // biggestSkippedOffer should have better rate than current offer
            if (biggestSkippedOffer.payAmount >= remainingSrcAmount) {
                offers[numTakenOffer].id = biggestSkippedOffer.id;
                offers[numTakenOffer].buyAmount = remainingSrcAmount * biggestSkippedOffer.buyAmount / biggestSkippedOffer.payAmount;
                offers[numTakenOffer].payAmount = remainingSrcAmount;
                totalDestAmount += offers[numTakenOffer].buyAmount;
                ++numTakenOffer;
                remainingSrcAmount = 0;
                break;
            } else if (offers[numTakenOffer].payAmount >= remainingSrcAmount) {
                offers[numTakenOffer].buyAmount = remainingSrcAmount * offers[numTakenOffer].buyAmount / offers[numTakenOffer].payAmount;
                offers[numTakenOffer].payAmount = remainingSrcAmount;
                totalDestAmount += offers[numTakenOffer].buyAmount;
                ++numTakenOffer;
                remainingSrcAmount = 0;
                break;
            } else if ((maxOrdersToTake - numTakenOffer) > 1) {
                totalDestAmount += offers[numTakenOffer].buyAmount;
                remainingSrcAmount -= offers[numTakenOffer].payAmount;
                ++numTakenOffer;
            } else if (offers[numTakenOffer].payAmount > biggestSkippedOffer.payAmount) {
                biggestSkippedOffer.payAmount = offers[numTakenOffer].payAmount;
                biggestSkippedOffer.buyAmount = offers[numTakenOffer].buyAmount;
                biggestSkippedOffer.id = offers[numTakenOffer].id;
            }

            offers[numTakenOffer].id = otc.getWorseOffer(offers[thisOffer].id);
            (offers[numTakenOffer].buyAmount, , offers[numTakenOffer].payAmount, ) = otc.getOffer(offers[numTakenOffer].id);
        }

        if (remainingSrcAmount > 0) totalDestAmount = 0;
        if (totalDestAmount == 0) offers = new OfferData[](0);
    }

    // bid: buy WETH, ask: sell WETH (their base token is DAI)
    function getFirstBidAndAskOrders(IERC20 token)
        internal view
        returns(OfferData memory bid, OfferData memory ask)
    {
        // getting first bid offer (buy WETH)
        (bid.id, bid.payAmount, bid.buyAmount) = getFirstOffer(token, wethToken);
        // getting first ask offer (sell WETH)
        (ask.id, ask.payAmount, ask.buyAmount) = getFirstOffer(wethToken, token);
    }

    function getFirstOffer(IERC20 offerSellGem, IERC20 offerBuyGem)
        internal view
        returns(uint offerId, uint offerPayAmount, uint offerBuyAmount)
    {
        offerId = otc.getBestOffer(offerSellGem, offerBuyGem);
        (offerBuyAmount, , offerPayAmount, ) = otc.getOffer(offerId);
    }
}

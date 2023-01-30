/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity ^0.5.10;
pragma experimental ABIEncoderV2;

interface MatchingMarket {
    function offers(uint256 id) external view returns(uint256 pay_amt, address pay_gem, uint256 buy_amt, address buy_gem, address owner, uint64 timestamp);
    function getOfferCount(address base, address quote) external view returns(uint256 count);
    function getBestOffer(address base, address quote) external view returns(uint256 id);
    function getWorseOffer(uint256 id) external view returns(uint256 worseOfferId);
}

contract OasisOrderbook {
    struct Offer {
        uint256 id;
        address maker;
        uint256 makerAmount;
        uint256 takerAmount;
    }

    MatchingMarket oasisMarket = MatchingMarket(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);

    function getOrderbook(address base, address quote) external view returns(Offer[] memory bids, Offer[] memory asks) {
        uint256 offerId;
        uint256 bidCount = oasisMarket.getOfferCount(quote, base);
        bids = new Offer[](bidCount);
        offerId = oasisMarket.getBestOffer(quote, base);
        bids[0] = getOffer(offerId);
        for (uint256 i = 1; i < bidCount; i++) {
            offerId = oasisMarket.getWorseOffer(offerId);
            bids[i] = getOffer(offerId);
        }
        uint256 askCount = oasisMarket.getOfferCount(base, quote);
        asks = new Offer[](askCount);
        offerId = oasisMarket.getBestOffer(base, quote);
        asks[0] = getOffer(offerId);
        for (uint256 i = 1; i < askCount; i++) {
            offerId = oasisMarket.getWorseOffer(offerId);
            asks[i] = getOffer(offerId);
        }
    }

    function getOffer(uint256 id) private view returns(Offer memory offer) {
        (uint256 pay_amt, , uint256 buy_amt, , address owner, ) = oasisMarket.offers(id);
        offer = Offer(id, owner, pay_amt, buy_amt);
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
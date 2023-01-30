/**
 *Submitted for verification at Etherscan.io on 2019-09-08
*/

pragma solidity ^0.5.9;


interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract OtcInterface {
    function getOffer(uint id) external view returns (uint, ERC20, uint, ERC20);
    function getBestOffer(ERC20 sellGem, ERC20 buyGem) external view returns(uint);
    function getWorseOffer(uint id) external view returns(uint);
    function take(bytes32 id, uint128 maxTakeAmount) external;
}


contract WethInterface is ERC20 {
    function deposit() public payable;
    function withdraw(uint) public;
}


contract ShowEth2DAI {
     // constants
    uint constant BASE_TAKE_OFFERS = 2;
    uint constant BASE_TRAVERSE_OFFERS = 6;
    uint constant  MIN_TAKE_AMOUNT_DAI = 30;
    uint  constant internal MAX_QTY   = (10**28); // 10B tokens
    uint constant MAX_TAKE_ORDERS = 8;
    uint constant MAX_TRAVERSE_ORDERS = 20;
    uint constant MIN_TAKE_SIZE_DAI = 35; // ~ $35 = 100000; //according to off chain checks.
    uint constant BIGGEST_MIN_TAKE_AMOUNT_DAI = 80;
    
    // values
    uint public offerDAIFactor = 700; // $700 
    address public admin;
    uint constant INVALID_ID = uint(-1);
    uint constant internal COMMON_DECIMALS = 18;
    OtcInterface public otc = OtcInterface(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);
    WethInterface public wethToken = WethInterface(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 public DAIToken = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    
    constructor() public {
        require(wethToken.decimals() == COMMON_DECIMALS);
    
        require(DAIToken.approve(address(otc), 2**255));
        require(wethToken.approve(address(otc), 2**255));
    }

    function() external payable {
        
    }
    
    function calcDaiTokenAmount (bool isEthToDai, uint payAmount, uint buyAmount, uint srcAmount) public pure returns (uint daiAmount, uint daiTokens) {
        daiAmount = isEthToDai ? srcAmount * buyAmount / payAmount : srcAmount;
        daiTokens = daiAmount / 10 ** 18;
    }

    struct OfferData {
        uint payAmount;
        uint buyAmount;
        uint id;
    }
    
    function showBestOffers(bool isEthToDai, uint srcAmountToken) public view
        returns(uint destAmount, uint destAmountToken, uint [] memory offerIds) 
    {
        OfferData [] memory offers;
        ERC20 dstToken = isEthToDai ? DAIToken : wethToken;
        ERC20 srcToken = isEthToDai ? wethToken : DAIToken;

        (destAmount, offers) = findBestOffers(dstToken, srcToken, (srcAmountToken * 10 ** 18));
        
        destAmountToken = destAmount / 10 ** 17;
        
        uint i;
        for (i; i < offers.length; i++) {
            if(offers[i].id == 0) {
                break;
            }
        }
    
        offerIds = new uint[](i);
        for (i = 0; i < offerIds.length; i++) {
            offerIds[i] = offers[i].id;
        }
    }    
    
    function findBestOffers(ERC20 dstToken, ERC20 srcToken, uint srcAmount) internal view
       returns(uint totalDestAmount, OfferData [] memory offers)
    {
        uint remainingSrcAmount = srcAmount;
        uint maxOrdersToTake;
        uint maxTraversedOrders;
        uint minTakeAmount;
        uint numTakenOffer;

        offers = new OfferData[](MAX_TRAVERSE_ORDERS);

        // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
        offers[0].id = otc.getBestOffer(dstToken, srcToken);
        // assuming pay amount is taker pay amount. (in otc it is used differently)
        (offers[0].payAmount, , offers[0].buyAmount, ) = otc.getOffer(offers[0].id);

        (maxOrdersToTake, maxTraversedOrders, minTakeAmount) = calcOfferLimits(
            (srcToken == wethToken),
            offers[0].payAmount,
            offers[0].buyAmount,
            remainingSrcAmount);

        uint thisOffer;

        OfferData memory biggestSkippedOffer;

        for ( ; maxTraversedOrders > 0; --maxTraversedOrders) {
            thisOffer = numTakenOffer;

            if (biggestSkippedOffer.payAmount > remainingSrcAmount) {
                offers[numTakenOffer].id = biggestSkippedOffer.id;
                offers[numTakenOffer].buyAmount = biggestSkippedOffer.payAmount * remainingSrcAmount / biggestSkippedOffer.buyAmount;
                offers[numTakenOffer].payAmount = remainingSrcAmount;
                totalDestAmount += offers[numTakenOffer].buyAmount;
                ++numTakenOffer ;
                remainingSrcAmount = 0;
                break;
            } else if (offers[numTakenOffer].payAmount > remainingSrcAmount) {
                offers[numTakenOffer].buyAmount = offers[numTakenOffer].payAmount * remainingSrcAmount / offers[numTakenOffer].buyAmount;
                offers[numTakenOffer].payAmount = remainingSrcAmount;
                totalDestAmount += offers[numTakenOffer].buyAmount;
                ++numTakenOffer;
                remainingSrcAmount = 0;
                break;
            } else if ((maxOrdersToTake - numTakenOffer) > 1 &&
                minTakeAmount < offers[numTakenOffer].payAmount)
            {
                totalDestAmount += offers[numTakenOffer].buyAmount;
                remainingSrcAmount -= offers[numTakenOffer].payAmount;
                ++numTakenOffer;
            } else if (offers[numTakenOffer].payAmount > biggestSkippedOffer.payAmount) {
                biggestSkippedOffer.payAmount = offers[numTakenOffer].payAmount;
                biggestSkippedOffer.buyAmount = offers[numTakenOffer].buyAmount;
                biggestSkippedOffer.id = offers[numTakenOffer].id;
            }

            offers[numTakenOffer].id = otc.getWorseOffer(offers[thisOffer].id);
            (offers[numTakenOffer].payAmount, , offers[numTakenOffer].buyAmount, ) = otc.getOffer(offers[numTakenOffer
            ].id);
        }

        if (remainingSrcAmount > 0) totalDestAmount = 0;
        if (totalDestAmount == 0) numTakenOffer = 0;
    }

    function takeBestOffers(ERC20 dstToken, ERC20 srcToken, uint srcAmount) internal returns(uint actualDestAmount) {
        OfferData [] memory offers;

        (actualDestAmount, offers) = findBestOffers(dstToken, srcToken, srcAmount);

        for (uint i = 0; i < offers.length; ++i) {

            if (offers[i].payAmount == 0) break;
            require(offers[i].payAmount <= MAX_QTY);
            otc.take(bytes32(offers[i].id), uint128(offers[i].payAmount));  // Take the portion of the offer that we need
        }

        return actualDestAmount;
    }

    function calcOfferLimits(bool isEthToDai, uint order0Pay, uint order0Buy, uint srcAmount) public view
        returns(uint maxTakes, uint maxTraverse, uint minAmountPayToken)
    {
        uint daiOrderSize = isEthToDai ? srcAmount * order0Pay / order0Buy : srcAmount;
        uint offerLevel = daiOrderSize / 10 ** 18 / offerDAIFactor;
        uint minAmountDai;
        
        maxTakes = BASE_TAKE_OFFERS + offerLevel;
        maxTakes = maxTakes > MAX_TAKE_ORDERS ? MAX_TAKE_ORDERS : maxTakes;
        maxTraverse = BASE_TRAVERSE_OFFERS + 2 * offerLevel;
        maxTraverse = maxTraverse > MAX_TRAVERSE_ORDERS ? MAX_TRAVERSE_ORDERS : maxTraverse;
        minAmountDai = MIN_TAKE_SIZE_DAI + 5 * offerLevel;
        minAmountDai = minAmountDai > BIGGEST_MIN_TAKE_AMOUNT_DAI ? BIGGEST_MIN_TAKE_AMOUNT_DAI : minAmountDai;

        // translate min amount to pay token
        minAmountPayToken = isEthToDai ? minAmountDai * order0Pay / order0Buy : minAmountDai;
    }

    function getNextBestOffer(
        ERC20 offerSellGem,
        ERC20 offerBuyGem,
        uint payAmount,
        uint prevOfferId
    )
        internal
        view
        returns(
            uint offerId,
            uint offerPayAmount,
            uint offerBuyAmount
        )
    {
        if (prevOfferId == INVALID_ID) {
            offerId = otc.getBestOffer(offerSellGem, offerBuyGem);
        } else {
            offerId = otc.getWorseOffer(prevOfferId);
        }

        (offerPayAmount, ,offerBuyAmount, ) = otc.getOffer(offerId);

        while (payAmount > offerPayAmount) {
            offerId = otc.getWorseOffer(offerId); // next best offer
            if (offerId == 0) {
                offerId = 0;
                offerPayAmount = 0;
                offerBuyAmount = 0;
                break;
            }
            (offerPayAmount, ,offerBuyAmount, ) = otc.getOffer(offerId);
        }
    }
    
    function getEthToDaiOrders(uint numOrders) public view
        returns(uint [] memory ethPayAmtTokens, uint [] memory daiBuyAmtTokens, uint [] memory rateDaiDivEthx10, uint [] memory Ids) 
    {
        uint offerId = INVALID_ID;
        ethPayAmtTokens = new uint[](numOrders);
        daiBuyAmtTokens = new uint[](numOrders);    
        rateDaiDivEthx10 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;
        
        for (uint i = 0; i < numOrders; i++) {
            
            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(DAIToken, wethToken, 1, offerId);
            
            ethPayAmtTokens[i] = offerPayAmt / 10 ** 18;
            daiBuyAmtTokens[i] = offerBuyAmt / 10 ** 18;
            rateDaiDivEthx10[i] = (offerPayAmt * 10) / offerBuyAmt;
            Ids[i] = offerId;
            
            if(offerId == 0) break;
        }
    }
    
    function getDaiToEthOrders(uint numOrders) public view
        returns(uint [] memory daiPayAmtTokens, uint [] memory ethBuyAmtTokens, uint [] memory rateDaiDivEthx10, uint [] memory Ids)
    {
        uint offerId = INVALID_ID;
        daiPayAmtTokens = new uint[](numOrders);
        ethBuyAmtTokens = new uint[](numOrders);
        rateDaiDivEthx10 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;

        for (uint i = 0; i < numOrders; i++) {

            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(wethToken, DAIToken, 1, offerId);

            daiPayAmtTokens[i] = offerPayAmt / 10 ** 18;
            ethBuyAmtTokens[i] = offerBuyAmt / 10 ** 18;
            rateDaiDivEthx10[i] = (offerBuyAmt * 10) / offerPayAmt;
            Ids[i] = offerId;
            
            if(offerId == 0) break;
        }
    }
}
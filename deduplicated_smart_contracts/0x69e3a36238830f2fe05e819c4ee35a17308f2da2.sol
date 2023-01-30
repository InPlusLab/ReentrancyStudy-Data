/**
 *Submitted for verification at Etherscan.io on 2019-09-04
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


contract TradeEth2DAI {
    // constants
    uint constant BASE_TAKE_OFFERS = 2;
    uint constant BASE_TRAVERSE_OFFERS = 6;
    uint constant  MIN_TAKE_AMOUNT_DAI = 30;
    uint constant  BIGGEST_MIN_TAKE_AMOUNT_DAI = 90;
    uint  constant internal MAX_QTY   = (10**28); // 10B tokens
    uint constant MAX_TAKE_ORDERS = 5;
    uint constant MAX_TRAVERSE_ORDERS = 20;
    uint constant TAKE_ORDER_GAS_COST = 100000; //according to off chain checks.
    
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
    
        admin = msg.sender;

        require(DAIToken.approve(address(otc), 2**255));
        require(wethToken.approve(address(otc), 2**255));
    }

    function() external payable {
        
    }
    
    function setOfferDAIFactor(uint factor) public {
        offerDAIFactor = factor;    
    }
    
    event TradeExecute(
        address indexed sender,
        bool isEthToDai,
        uint srcAmount,
        uint destAmount,
        address destAddress
    );

    function tradeEthVsDAI(
        uint numTakeOrders,
        uint numTraverseOrders,
        bool isEthToDai,
        uint srcAmount
    )
        public
        payable
    {
        address payable dstAddress = msg.sender;
        uint userTotalDestAmount;
        
        if (isEthToDai) {
            require(msg.value == srcAmount);
            wethToken.deposit.value(msg.value)();
            userTotalDestAmount = takeOrders(wethToken, DAIToken, srcAmount, numTakeOrders, numTraverseOrders);
            require(DAIToken.transfer(dstAddress, userTotalDestAmount));
        } else {
            //Dai To Eth
            require(DAIToken.transferFrom(msg.sender, address(this), srcAmount));
            userTotalDestAmount = takeOrders(DAIToken, wethToken, srcAmount, numTakeOrders, numTraverseOrders);
            wethToken.withdraw(userTotalDestAmount);    
            dstAddress.transfer(userTotalDestAmount);
        }

        emit TradeExecute(msg.sender, isEthToDai, srcAmount, userTotalDestAmount, dstAddress);
    }

    function getNextOffer(uint prevOfferId, bool isEthToDai) public view
        returns(uint offerId, uint offerPayAmount, uint offerBuyAmount) 
    {
        uint prevId = prevOfferId == 0 ? INVALID_ID : prevOfferId;       
        
        if(isEthToDai) {
            // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
            return(getNextBestOffer(DAIToken, wethToken, 1, prevId));
        }
        
        // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
        return(getNextBestOffer(wethToken, DAIToken, 1, prevId));
    }
    
    struct OfferDescriptor {
        uint payAmount;
        uint buyAmount;
        uint id;
    }
    
    function showBestOffers1(bool isEthToDai, uint srcAmountTokenx10) public view
        returns(uint destAmount, uint destAmountTokenx10, uint numTaken, uint numTraversed, uint [] memory offerIds, 
            uint maxTakes, uint maxTraverse, uint minTakeAmount) 
    {
        OfferDescriptor [] memory offers;
        (destAmount, numTaken, numTraversed, offers, maxTakes, maxTraverse, minTakeAmount) = findBestOffers(isEthToDai, (srcAmountTokenx10 * 10 ** 17), calcOfferLimits1);
        
        
        destAmountTokenx10 = destAmount / 10 ** 17;
        
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
    
    function showBestOffers2(bool isEthToDai, uint srcAmountTokenx10) public view
        returns(uint destAmount, uint destAmountTokenx10, uint numTaken, uint numTraversed, uint [] memory offerIds, 
            uint maxTakes, uint maxTraverse, uint minTakeAmount) 
    {
        OfferDescriptor [] memory offers;
        (destAmount, numTaken, numTraversed, offers, maxTakes, maxTraverse, minTakeAmount) = findBestOffers(isEthToDai, (srcAmountTokenx10 * 10 ** 17), calcOfferLimits2);
        
        destAmountTokenx10 = destAmount / 10 ** 17;
        
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
    
    
    function showBestOffers3(bool isEthToDai, uint srcAmountTokenx10) public view
        returns(uint destAmount, uint destAmountTokenx10, uint numTaken, uint numTraversed, uint [] memory offerIds, 
            uint maxTakes, uint maxTraverse, uint minTakeAmount) 
    {
        OfferDescriptor [] memory offers;
        (destAmount, numTaken, numTraversed, offers, maxTakes, maxTraverse, minTakeAmount) = findBestOffers(isEthToDai, (srcAmountTokenx10 * 10 ** 17), calcOfferLimits3);
        
        destAmountTokenx10 = destAmount / 10 ** 17;
        
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
    
    function findBestOffers(bool isEthToDai, uint srcAmount, function (bool, uint, uint, uint) view returns (uint, uint, uint) calcLim) 
        internal view
        returns(uint totalDestAmount, uint numTaken, uint numTraversed, OfferDescriptor [] memory offers, uint remainingTakeOrders, uint maxTraverse, uint minAmount) 
    {
        uint remainingSrcAmount = srcAmount;
        offers = new OfferDescriptor[](MAX_TRAVERSE_ORDERS);
        
        ERC20 srcToken = isEthToDai ? wethToken : DAIToken;
        ERC20 dstToken = isEthToDai ? DAIToken : wethToken;
        
        // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
        offers[0].id = otc.getBestOffer(dstToken, srcToken);
        (offers[0].payAmount, , offers[0].buyAmount, ) = otc.getOffer(offers[0].id);
        
        (remainingTakeOrders, maxTraverse, minAmount) = calcLim(isEthToDai, offers[0].payAmount, offers[0].buyAmount, srcAmount); 
        uint thisOffer;
        numTraversed = 1;
        // uint remainingTakeOrders = maxTakes;
        
        OfferDescriptor memory biggestSkippedOffer;
        
        for (uint i = 0; i < maxTraverse; ++i) {
            thisOffer = numTaken;
            
            if (remainingSrcAmount < biggestSkippedOffer.payAmount) {
                offers[numTaken].id = biggestSkippedOffer.id;
                offers[numTaken].buyAmount = biggestSkippedOffer.payAmount * remainingSrcAmount / biggestSkippedOffer.buyAmount;
                offers[numTaken].payAmount = remainingSrcAmount;
                totalDestAmount += offers[numTaken].buyAmount;
                ++numTaken;
                remainingSrcAmount = 0;
                break; 
            } else if (offers[numTaken].payAmount > remainingSrcAmount) {
                offers[numTaken].buyAmount = offers[numTaken].payAmount * remainingSrcAmount / offers[numTaken].buyAmount;
                offers[numTaken].payAmount = remainingSrcAmount;
                totalDestAmount += offers[numTaken].buyAmount;
                ++numTaken;
                remainingSrcAmount = 0;
                break;
            } else if (remainingTakeOrders > 1 && 
                    minAmount < offers[numTaken].payAmount) 
            {
                    totalDestAmount += offers[numTaken].buyAmount;
                    remainingSrcAmount -= offers[numTaken].payAmount;
                    --remainingTakeOrders;
                    ++numTaken;
            } else if (offers[numTaken].payAmount > biggestSkippedOffer.payAmount) {
                biggestSkippedOffer.payAmount = offers[numTaken].payAmount;
                biggestSkippedOffer.buyAmount = offers[numTaken].buyAmount;
                biggestSkippedOffer.id = offers[numTaken].id;
            }

            offers[numTaken].id = otc.getWorseOffer(offers[thisOffer].id);
            (offers[numTaken].payAmount, , offers[numTaken].buyAmount, ) = otc.getOffer(offers[numTaken].id);
        
            ++numTraversed;
        }
        
        if (totalDestAmount == 0) numTaken = 0;
        
        if (remainingSrcAmount > 0) totalDestAmount = 0;
    }
    
    function calcDaiAmount (bool isEthToDai, uint payAmount, uint buyAmount, uint srcAmount) public view returns (uint daiAmount, uint daiTokens) {
        daiAmount = isEthToDai ? srcAmount * buyAmount / payAmount : srcAmount;
        daiTokens = daiAmount / 10 ** 18;
    }
    
    function calcOfferLimits1(bool isEthToDai, uint payAmount, uint buyAmount, uint srcAmount) internal view 
        returns(uint maxTakes, uint maxTraverse, uint minAmount) 
    {
        uint daiSrcAmount;
        (daiSrcAmount, ) = calcDaiAmount(isEthToDai, payAmount, buyAmount, srcAmount); 
        uint offerLevel = daiSrcAmount / 10 ** 18 / offerDAIFactor;
        
        maxTakes = BASE_TAKE_OFFERS + offerLevel;
        maxTakes = maxTakes > MAX_TAKE_ORDERS ? MAX_TAKE_ORDERS : maxTakes;
        maxTraverse = BASE_TRAVERSE_OFFERS + 2 * offerLevel;
        maxTraverse = maxTraverse > MAX_TRAVERSE_ORDERS ? MAX_TRAVERSE_ORDERS : maxTraverse;
        minAmount = srcAmount / maxTakes / 2;
        minAmount = minAmount > BIGGEST_MIN_TAKE_AMOUNT_DAI ? BIGGEST_MIN_TAKE_AMOUNT_DAI : minAmount;
    }
    
    function calcOfferLimits2(bool isEthToDai, uint payAmount, uint buyAmount, uint srcAmount) internal view 
        returns(uint maxTakes, uint maxTraverse, uint minAmount)
    {
        uint daiSrcAmount;
        (daiSrcAmount, ) = calcDaiAmount(isEthToDai, payAmount, buyAmount, srcAmount); 
        uint offerLevel = daiSrcAmount / 10 ** 18 / offerDAIFactor;
        
        maxTakes = BASE_TAKE_OFFERS + offerLevel;
        maxTakes = maxTakes > MAX_TAKE_ORDERS ? MAX_TAKE_ORDERS : maxTakes;
        maxTraverse = BASE_TRAVERSE_OFFERS + 2 * offerLevel;
        maxTraverse = maxTraverse > MAX_TRAVERSE_ORDERS ? MAX_TRAVERSE_ORDERS : maxTraverse;
        minAmount = isEthToDai ? MIN_TAKE_AMOUNT_DAI * buyAmount / payAmount : MIN_TAKE_AMOUNT_DAI;
    }

    function calcOfferLimits3(bool isEthToDai, uint payAmount, uint buyAmount, uint srcAmount) internal view 
        returns(uint maxTakes, uint maxTraverse, uint minAmount) 
    {
        uint daiSrcAmount;
        (daiSrcAmount, ) = calcDaiAmount(isEthToDai, payAmount, buyAmount, srcAmount); 
        uint offerLevel = daiSrcAmount * 2 / 10 ** 18 / offerDAIFactor;
        
        maxTakes = BASE_TAKE_OFFERS + 1 + offerLevel;
        maxTakes = maxTakes > MAX_TAKE_ORDERS ? MAX_TAKE_ORDERS : maxTakes;
        maxTraverse = BASE_TRAVERSE_OFFERS + 2 + (2 * offerLevel);
        maxTraverse = maxTraverse > MAX_TRAVERSE_ORDERS ? MAX_TRAVERSE_ORDERS : maxTraverse;
        minAmount = srcAmount / maxTakes / 3;
        minAmount = minAmount > BIGGEST_MIN_TAKE_AMOUNT_DAI ? BIGGEST_MIN_TAKE_AMOUNT_DAI : minAmount;
    }
    
    function takeOrders(ERC20 srcToken, ERC20 dstToken, uint srcAmount, uint numTakeOrders, uint numTraverseOrders) 
        internal 
        returns(uint userTotalDestAmount)
    {
        uint remainingAmount = srcAmount;
        uint destAmount;
        uint offerId = INVALID_ID;
        uint i;
        
        for (i = numTraverseOrders; i > 0; i--) {
            //this loop to see cost of 'peeking' into order
            (offerId, , ) = getNextBestOffer(dstToken, srcToken, remainingAmount / i, offerId);
            
            require(offerId > 0);
        }
        
        for (i = numTakeOrders; i > 0; i--) {
            
            // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
            (offerId, , ) = getNextBestOffer(dstToken, srcToken, remainingAmount / i, offerId);
            
            require(offerId > 0);
            
            destAmount = takeMatchingOffer(remainingAmount / i, offerId);
            userTotalDestAmount += destAmount;
            remainingAmount -= (remainingAmount / i);
        }
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

        (offerPayAmount, , offerBuyAmount, ) = otc.getOffer(offerId);

        while (payAmount > offerBuyAmount) {
            offerId = otc.getWorseOffer(offerId); // next best offer
            if (offerId == 0) {
                offerId = 0;
                offerPayAmount = 0;
                offerBuyAmount = 0;
                break;
            }
            (offerPayAmount, , offerBuyAmount, ) = otc.getOffer(offerId);
        }
    }
    
    function takeOffer(uint payAmount, uint buyAmount, uint offerId) internal {
        require(payAmount <= MAX_QTY);
        otc.take(bytes32(offerId), uint128(buyAmount));  // Take the portion of the offer that we need
        return;
    }

    function takeMatchingOffer(
        uint srcAmount, 
        uint offerId
    )
        internal
        returns(uint actualDestAmount)
    {
        uint offerPayAmt;
        uint offerBuyAmt;

        // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
        (offerPayAmt, , offerBuyAmt, ) = otc.getOffer(offerId);
        
        actualDestAmount = srcAmount * offerPayAmt / offerBuyAmt;

        require(uint128(actualDestAmount) == actualDestAmount);
        otc.take(bytes32(offerId), uint128(actualDestAmount));  // Take the portion of the offer that we need
        return(actualDestAmount);
    }
    
    function getEthToDaiOrders(uint numOrders) public view
        returns(uint [] memory ethAmtTokens, uint [] memory daiAmtTokens, uint [] memory rateDaiDivEthx10, uint [] memory Ids) 
    {
        uint offerId = INVALID_ID;
        ethAmtTokens = new uint[](numOrders);
        daiAmtTokens = new uint[](numOrders);    
        rateDaiDivEthx10 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;
        
        for (uint i = 0; i < numOrders; i++) {
            
            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(DAIToken, wethToken, 1, offerId);
            
            ethAmtTokens[i] = offerBuyAmt / 10 ** 18;
            daiAmtTokens[i] = offerPayAmt / 10 ** 18;
            rateDaiDivEthx10[i] = (offerPayAmt * 10) / offerBuyAmt;
            Ids[i] = offerId;
            
            if(offerId == 0) break;
        }
    }
    
    function getDaiToEthOrders(uint numOrders) public view
        returns(uint [] memory daiAmtTokens, uint [] memory ethAmtTokens, uint [] memory rateDaiDivEthx10, uint [] memory Ids)
    {
        uint offerId = INVALID_ID;
        daiAmtTokens = new uint[](numOrders);
        ethAmtTokens = new uint[](numOrders);
        rateDaiDivEthx10 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;

        for (uint i = 0; i < numOrders; i++) {

            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(wethToken, DAIToken, 1, offerId);

            daiAmtTokens[i] = offerBuyAmt / 10 ** 18;
            ethAmtTokens[i] = offerPayAmt / 10 ** 18;
            rateDaiDivEthx10[i] = (offerPayAmt * 10) / offerBuyAmt;
            Ids[i] = offerId;
            
            if(offerId == 0) break;
        }
    }
}
/**
 *Submitted for verification at Etherscan.io on 2019-09-03
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
    
    address public admin;
    uint constant INVALID_ID = uint(-1);
    uint constant internal COMMON_DECIMALS = 18;
    OtcInterface public otc = OtcInterface(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);
    WethInterface public wethToken = WethInterface(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 public DAIToken = ERC20(0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359);
    uint  constant internal MAX_QTY   = (10**28); // 10B tokens
    uint constant BASE_TAKE_ORDERS = 2;
    uint constant MAX_TAKE_ORDERS = 5;
    uint constant BASE_TRAVERSE_ORDERS = 7;
    uint constant MAX_TRAVERSE_ORDERS = 20;
    uint constant NUM_TAKE_ORDERS_FACTOR = 3 * 10 ** 18; // 3 Eth
    uint constant NUM_TRAVERSE_ORDERS_FACTOR = 10 ** 18; // 1 Eth
    uint constant TAKE_ORDER_GAS_COST = 100000; //according to off chain checks.
    
    constructor() public {
        require(wethToken.decimals() == COMMON_DECIMALS);
    
        admin = msg.sender;

        require(DAIToken.approve(address(otc), 2**255));
        require(wethToken.approve(address(otc), 2**255));
    }

    function() external payable {
        
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
    
    function showBestOffers(bool isEthToDai, uint srcAmount) public 
        returns(uint totalDestAmount, uint numOffers, uint [] memory offerIds) 
    {
        OfferDescriptor [] memory offers;
        (totalDestAmount, numOffers, , offers) = findBestOffers(isEthToDai, srcAmount);
        
        offerIds = new uint[](offers.length);
        
        for (uint i; i < offers.length; i++) {
            offerIds[i] = offers[i].id;
        }
    }
    
    function findBestOffers(bool isEthToDai, uint srcAmount) internal 
        returns(uint totalDestAmount, uint numTaken, uint numTraversed, OfferDescriptor [] memory offers) 
    {
        uint remainingSrcAmount = srcAmount;
        offers = new OfferDescriptor[](MAX_TRAVERSE_ORDERS);
        uint minTakeAmount = 5 ** 18; // 0.5 eth
        uint remainingTakeOrders;
        uint maxTraversedOrders;
        
        ERC20 srcToken = isEthToDai ? wethToken : DAIToken;
        ERC20 dstToken = isEthToDai ? DAIToken : wethToken;
        uint thisOffer;
        
        numTraversed = 1;
        
        // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
        offers[0].id = otc.getBestOffer(dstToken, srcToken);
        (offers[0].payAmount, , offers[0].buyAmount, ) = otc.getOffer(offers[0].id);
        
        (remainingTakeOrders, maxTraversedOrders) = 
            calcOfferParams(true, offers[0].payAmount, offers[0].buyAmount, srcAmount);
        
        for (uint i = 0; i < maxTraversedOrders; ++i) {
            thisOffer = numTaken;
            
            if (offers[numTaken].payAmount > remainingSrcAmount) {
                offers[numTaken].buyAmount = offers[numTaken].payAmount * remainingSrcAmount / offers[numTaken].buyAmount;
                offers[numTaken].payAmount = remainingSrcAmount;
                totalDestAmount += offers[numTaken].buyAmount;
                ++numTaken;
                remainingSrcAmount = 0;
                break;
            } else {
                if (remainingTakeOrders > 1 && 
                    minTakeAmount < (isEthToDai ? offers[numTaken].payAmount : offers[numTaken].buyAmount)) 
                {
                    totalDestAmount += offers[numTaken].buyAmount;
                    remainingSrcAmount -= offers[numTaken].payAmount;
                    --remainingTakeOrders;
                    ++numTaken;
                }
            }

            offers[numTaken].id = otc.getWorseOffer(offers[thisOffer].id);
            (offers[numTaken].payAmount, , offers[numTaken].buyAmount, ) = otc.getOffer(offers[numTaken].id);
        
            ++numTraversed;
        }
        
        if (remainingSrcAmount > 0) totalDestAmount = 0;
    }
    
    // function takeBestOffers(bool isEthToDai, uint srcAmount) public returns(uint totalDestAmount) {
        
    //     uint remainingSrcAmount = srcAmount;
    //     uint destAmount;
    //     OfferDescriptor [] memory offers;
    //     offers = new OfferDescriptor[](MAX_TRAVERSE_ORDERS);
        
    //     uint remainingTakeOrders;
    //     uint maxTraversedOrders;
    //     uint takeCost = tx.gasprice * TAKE_ORDER_GAS_COST;
        
    //     // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
    //     uint offerId = otc.getBestOffer(dstToken, srcToken);
    //     (offers[0].payAmount, , offers[0].buyAmount, ) = otc.getOffer(offerId);
        
    //     (remainingTakeOrders, maxTraversedOrders) = 
    //         calcOfferParams(true, offers[0].payAmount, offers[0].buyAmount, srcAmount);
        
    //     for (uint i = 0; i < MAX_TRAVERSE_ORDERS && remainingSrcAmount > 0; ++i) {

    //         if (offers[i].payAmount > remainingSrcAmount) {
    //             if (!calcOnly) totalDestAmount += takeMatchingOffer(remainingSrcAmount, offerId);
    //             else totalDestAmount += remainingSrcAmount * offers[i].payAmount / offers[i].buyAmount;
    //             break;
    //         } else {
    //             offerId = otc.getWorseOffer(offerId);
    //             require(offerId > 0);
    //             (offers[i + 1].payAmount, , offers[i + 1].buyAmount, ) = otc.getOffer(offerId);
                
    //             if (remainingTakeOrders > 1) {
    //                 //is it very small?
    //                 if( (offers[i].payAmount > srcAmount / 2) || 
    //                     (remainingTakeOrders > 2 && offers[i].payAmount > remainingSrcAmount / 2)) {
    //                         destAmount = offers[i].buyAmount;
    //                 } else {
    //                     if (takeCost < calcSkipCost(srcToken, dstToken, offers[i].payAmount, offers[i].buyAmount, 
    //                         offers[i + 1].payAmount, offers[i + 1].buyAmount)) {
    //                             destAmount = offers[i].buyAmount;
    //                     }
    //                 }                
    //             }
    //         }
            
    //         if (destAmount > 0) {
    //             if (!calcOnly) destAmount = takeMatchingOffer(offers[i].payAmount, offerId);
    //             remainingSrcAmount -= offers[i].payAmount;
    //             totalDestAmount += destAmount;
    //             destAmount = 0;
    //         }
    //     }
    // }
    
    function calcOfferParams(bool isSrcEth, uint payAmount, uint buyAmount, uint srcAmount) internal 
        returns(uint maxTraversedOrders, uint maxTakeOrders) 
    {
        uint calcAmount = isSrcEth ? srcAmount : srcAmount * buyAmount / payAmount; 
        
        maxTakeOrders = BASE_TAKE_ORDERS + calcAmount / NUM_TAKE_ORDERS_FACTOR;
        maxTakeOrders = maxTakeOrders > MAX_TAKE_ORDERS ? MAX_TAKE_ORDERS : maxTakeOrders;
        
        maxTraversedOrders = BASE_TRAVERSE_ORDERS + calcAmount / NUM_TRAVERSE_ORDERS_FACTOR;            
        maxTraversedOrders = maxTraversedOrders > MAX_TRAVERSE_ORDERS ? MAX_TRAVERSE_ORDERS : maxTraversedOrders;
    }
    
    // function calcSkipCost(ERC20 payToken, ERC20 buyToken, uint pay1, uint buy1, uint pay2, uint buy2) internal 
    //     returns (uint skipOrderCost) 
    // {
    //     // calcucate skip cost in buyToken
    //     skipOrderCost = buy1 - (pay1 * buy2 / pay2);
        
    //     if (true) { //(buyToken != ETH) {
    //         // calcucate rate with both rate values we have
    //         skipOrderCost = skipOrderCost * (pay1 + pay2) / (buy1 + buy2); 
    //     }
    // }
    
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
        returns(uint [] memory ethPayAmtTokens, uint [] memory daiBuyAmtTokens, uint [] memory rate100KFactor) 
    {
        uint offerId = INVALID_ID;
        ethPayAmtTokens = new uint[](numOrders);
        daiBuyAmtTokens = new uint[](numOrders);    
        rate100KFactor = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;
        
        for (uint i = 0; i < numOrders; i++) {
            
            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(DAIToken, wethToken, 1, offerId);
            
            ethPayAmtTokens[i] = offerPayAmt / 10 ** 18;
            daiBuyAmtTokens[i] = offerBuyAmt / 10 ** 18;
            rate100KFactor[i] = offerBuyAmt * 100000 / offerPayAmt;
            
            if(offerId == 0) break;
        }
        
        return(daiBuyAmtTokens, ethPayAmtTokens, rate100KFactor);
    }
    
    function getDaiToEthOrders(uint numOrders) public view
        returns(uint [] memory daiPayAmtTokens, uint [] memory ethBuyAmtTokens, uint [] memory rateNoFactor)
    {
        uint offerId = INVALID_ID;
        daiPayAmtTokens = new uint[](numOrders);
        ethBuyAmtTokens = new uint[](numOrders);
        rateNoFactor = new uint[](numOrders);

        uint offerBuyAmt;
        uint offerPayAmt;

        for (uint i = 0; i < numOrders; i++) {

            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(wethToken, DAIToken, 1, offerId);

            daiPayAmtTokens[i] = offerPayAmt / 10 ** 18;
            ethBuyAmtTokens[i] = offerBuyAmt / 10 ** 18;
            rateNoFactor[i] = offerBuyAmt / offerPayAmt;

            if(offerId == 0) break;
        }

        return(ethBuyAmtTokens, daiPayAmtTokens, rateNoFactor);
    }
}
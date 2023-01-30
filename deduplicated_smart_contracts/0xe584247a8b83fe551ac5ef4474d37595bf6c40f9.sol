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


contract ShowEth2DAI {
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
    
        require(DAIToken.approve(address(otc), 2**255));
        require(wethToken.approve(address(otc), 2**255));
    }

    function() external payable {
        
    }
    
       
    function calcDaiAmount (bool isEthToDai, uint payAmount, uint buyAmount, uint srcAmount) public view returns (uint daiAmount, uint daiTokens) {
        daiAmount = isEthToDai ? srcAmount * payAmount / buyAmount : srcAmount;
        daiTokens = daiAmount / 10 ** 18;
    }
    
    function calcOfferLimits1(bool isEthToDai, uint srcAmount) public view 
        returns(uint payAmount, uint buyAmount, uint payAmountTok, uint buyAmountTok, uint maxTakes, uint maxTraverse, uint minAmount) 
    {
          
        ERC20 srcToken = isEthToDai ? wethToken : DAIToken;
        ERC20 dstToken = isEthToDai ? DAIToken : wethToken;
        
        // otc's terminology is of offer maker, so their sellGem is our (the taker's) dest token.
        uint offerId = otc.getBestOffer(dstToken, srcToken);
        (payAmount, , buyAmount, ) = otc.getOffer(offerId);
        
        payAmountTok = payAmount / 10 ** 18;
        buyAmountTok = buyAmount / 10 ** 18;
        
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
    
    struct OfferDescriptor {
        uint payAmount;
        uint buyAmount;
        uint id;
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
    
    function getDaiToEthOrders(uint numOrders) public view
        returns(uint [] memory daiPayAmtTokens, uint [] memory ethBuyAmtTokens, uint [] memory rateDaiDivEthx10, uint [] memory Ids) 
    {
        uint offerId = INVALID_ID;
        ethBuyAmtTokens = new uint[](numOrders);
        daiPayAmtTokens = new uint[](numOrders);    
        rateDaiDivEthx10 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;
        
        for (uint i = 0; i < numOrders; i++) {
            
            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(DAIToken, wethToken, 1, offerId);
            
            ethBuyAmtTokens[i] = offerBuyAmt / 10 ** 18;
            daiPayAmtTokens[i] = offerPayAmt / 10 ** 18;
            rateDaiDivEthx10[i] = (offerPayAmt * 10) / offerBuyAmt;
            Ids[i] = offerId;
            
            if(offerId == 0) break;
        }
    }
    
    function getEthToDaiOrders(uint numOrders) public view
        returns(uint [] memory ethPayAmtTokens, uint [] memory daiBuyAmtTokens, uint [] memory rateDaiDivEthx10, uint [] memory Ids)
    {
        uint offerId = INVALID_ID;
        daiBuyAmtTokens = new uint[](numOrders);
        ethPayAmtTokens = new uint[](numOrders);
        rateDaiDivEthx10 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;

        for (uint i = 0; i < numOrders; i++) {

            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(wethToken, DAIToken, 1, offerId);

            daiBuyAmtTokens[i] = offerBuyAmt / 10 ** 18;
            ethPayAmtTokens[i] = offerPayAmt / 10 ** 18;
            rateDaiDivEthx10[i] = (offerBuyAmt * 10) / offerPayAmt;
            Ids[i] = offerId;
            
            if(offerId == 0) break;
        }
    }
}
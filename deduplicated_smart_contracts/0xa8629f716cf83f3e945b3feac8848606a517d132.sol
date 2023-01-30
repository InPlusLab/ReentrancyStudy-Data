/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

pragma solidity 0.5.11;


interface ERC20 {
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
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

/// @title Kyber utils and utils2 contracts
contract Utils {

    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    uint  constant internal PRECISION = (10**18);
    uint  constant internal MAX_QTY   = (10**28); // 10B tokens
    uint  constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
    uint  constant internal MAX_DECIMALS = 18;
    uint  constant internal ETH_DECIMALS = 18;

    mapping(address=>uint) internal decimals;

    /// @dev get the balance of a user.
    /// @param token The token type
    /// @return The balance
    function getBalance(ERC20 token, address user) public view returns(uint) {
        if (token == ETH_TOKEN_ADDRESS)
            return user.balance;
        else
            return token.balanceOf(user);
    }

    function setDecimals(ERC20 token) internal {
        if (token == ETH_TOKEN_ADDRESS)
            decimals[address(token)] = ETH_DECIMALS;
        else
            decimals[address(token)] = token.decimals();
    }

    function getDecimals(ERC20 token) internal view returns(uint) {
        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint tokenDecimals = decimals[address(token)];
        // moreover, very possible that old tokens have decimals 0
        // these tokens will just have higher gas fees.
        if (tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
        require(srcQty <= MAX_QTY);
        require(rate <= MAX_RATE);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns(uint) {
        require(dstQty <= MAX_QTY);
        require(rate <= MAX_RATE);
        
        //source quantity is rounded up. to avoid dest quantity being too low.
        uint numerator;
        uint denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcDestAmount(ERC20 src, ERC20 dest, uint srcAmount, uint rate) internal view returns(uint) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(ERC20 src, ERC20 dest, uint destAmount, uint rate) internal view returns(uint) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
        internal pure returns(uint)
    {
        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
        }
    }

    function minOf(uint x, uint y) internal pure returns(uint) {
        return x > y ? y : x;
    }
}


contract WethInterface is ERC20 {
    function deposit() public payable;
    function withdraw(uint) public;
}


contract MarketHelper is Utils {

    // constants
    uint constant internal INVALID_ID = uint(-1);
    uint constant internal POW_2_32 = 2 ** 32;
    uint constant internal POW_2_96 = 2 ** 96;
    uint constant internal BPS = 10000; // 10^4

    // values
    address public kyberNetwork;
    bool public tradeEnabled;
    uint public feeBps;

    OtcInterface public otc = OtcInterface(0x39755357759cE0d7f32dC8dC45414CCa409AE24e);
    WethInterface public wethToken = WethInterface(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    ERC20 public mkrToken = ERC20(0x9f8F72aA9304c8B593d555F12eF6589cC3A579A2);

    function getNextBestOffer(
        ERC20 offerSellGem,
        ERC20 offerBuyGem,
        uint payAmount,
        uint prevOfferId
    )
        public
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

        (offerBuyAmount, ,offerPayAmount, ) = otc.getOffer(offerId);

        while (payAmount > offerPayAmount) {
            offerId = otc.getWorseOffer(offerId); // next best offer
            if (offerId == 0) {
                offerId = 0;
                offerPayAmount = 0;
                offerBuyAmount = 0;
                break;
            }
            (offerBuyAmount, ,offerPayAmount, ) = otc.getOffer(offerId);
        }
    }

    function getOffers(ERC20 token, bool isEthToToken, uint numOrders) public view
    returns(uint [] memory ethPayAmtTokens, uint [] memory tokenBuyAmtTokens, uint [] memory rateTokenDivEthx1000, uint [] memory Ids,
        uint totalBuyAmountToken, uint totalPayAmountEthers, uint totalRateTokenDivEthx1000) 
    {
        uint offerId = INVALID_ID;
        ethPayAmtTokens = new uint[](numOrders);
        tokenBuyAmtTokens = new uint[](numOrders);    
        rateTokenDivEthx1000 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;
        
        for (uint i = 0; i < numOrders; i++) {
            
            if (isEthToToken) {
                (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(token, wethToken, 1, offerId);
                rateTokenDivEthx1000[i] = (offerBuyAmt * 1000) / offerPayAmt;
            } else {
                (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(wethToken, token, 1, offerId);
                rateTokenDivEthx1000[i] = (offerPayAmt * 1000) / offerBuyAmt;
            }

            totalBuyAmountToken += offerBuyAmt;
            totalPayAmountEthers += offerPayAmt;
            
            ethPayAmtTokens[i] = offerPayAmt / 10 ** 15;
            tokenBuyAmtTokens[i] = offerBuyAmt / 10 ** 15;
            Ids[i] = offerId;
            
            if(offerId == 0) break;
        }

        if (isEthToToken) {
            totalRateTokenDivEthx1000 = totalBuyAmountToken * 1000 / totalPayAmountEthers;
        } else {
            totalRateTokenDivEthx1000 = totalPayAmountEthers * 1000 / totalBuyAmountToken;
        }

        totalBuyAmountToken /= 10 ** 18;
        totalPayAmountEthers /= 10 ** 18;
    }

    function getEthToMkrOrders(uint numOrders) public view
        returns(uint [] memory ethPayAmtTokens, uint [] memory mkrBuyAmtTokens, uint [] memory rateMkrDivEthx1000, uint [] memory Ids,
        uint totalBuyAmountMkrToken, uint totalPayAmountEthers, uint totalRateMkrDivEthx1000) 
    {
        uint offerId = INVALID_ID;
        ethPayAmtTokens = new uint[](numOrders);
        mkrBuyAmtTokens = new uint[](numOrders);    
        rateMkrDivEthx1000 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;
        
        for (uint i = 0; i < numOrders; i++) {
            
            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(mkrToken, wethToken, 1, offerId);
            
            totalBuyAmountMkrToken += offerBuyAmt;
            totalPayAmountEthers += offerPayAmt;
            
            ethPayAmtTokens[i] = offerPayAmt / 10 ** 15;
            mkrBuyAmtTokens[i] = offerBuyAmt / 10 ** 15;
            rateMkrDivEthx1000[i] = (offerBuyAmt * 1000) / offerPayAmt;
            Ids[i] = offerId;
            
            if(offerId == 0) break;
        }
        
        totalRateMkrDivEthx1000 = totalBuyAmountMkrToken * 1000 / totalPayAmountEthers;
        totalBuyAmountMkrToken /= 10 ** 15;
        totalPayAmountEthers /= 10 ** 15;
    }
    
    function getMkrToEthOrders(uint numOrders) public view
        returns(uint [] memory mkrPayAmtTokens, uint [] memory ethBuyAmtTokens, uint [] memory rateMkrDivEthx1000, uint [] memory Ids,
        uint totalPayAmountMkrToken, uint totalBuyAmountEthers, uint totalRateMkrDivEthx1000)
    {
        uint offerId = INVALID_ID;
        mkrPayAmtTokens = new uint[](numOrders);
        ethBuyAmtTokens = new uint[](numOrders);
        rateMkrDivEthx1000 = new uint[](numOrders);
        Ids = new uint[](numOrders);
        
        uint offerBuyAmt;
        uint offerPayAmt;

        for (uint i = 0; i < numOrders; i++) {

            (offerId, offerPayAmt, offerBuyAmt) = getNextBestOffer(wethToken, mkrToken, 1, offerId);
            
            totalPayAmountMkrToken += offerPayAmt;
            totalBuyAmountEthers += offerBuyAmt;
            
            mkrPayAmtTokens[i] = offerPayAmt / 10 ** 15;
            ethBuyAmtTokens[i] = offerBuyAmt / 10 ** 15;
            rateMkrDivEthx1000[i] = (offerPayAmt * 1000) / offerBuyAmt;
            Ids[i] = offerId;
            
            if (offerId == 0) break;
        }
        
        totalRateMkrDivEthx1000 = totalPayAmountMkrToken * 1000 / totalBuyAmountEthers;
        totalPayAmountMkrToken /= 10 ** 15;
        totalBuyAmountEthers /= 10 ** 15;
    }
}
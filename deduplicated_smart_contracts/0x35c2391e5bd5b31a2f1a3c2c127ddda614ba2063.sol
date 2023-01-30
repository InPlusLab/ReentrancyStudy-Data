/**
 *Submitted for verification at Etherscan.io on 2020-11-12
*/

// File: contracts/sol6/IERC20.sol

pragma solidity 0.6.6;


interface IERC20 {
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function decimals() external view returns (uint8 digits);

    function totalSupply() external view returns (uint256 supply);
}


interface IConversionRates {
    
    function getRate(
        IERC20 token,
        uint256 currentBlockNumber,
        bool buy,
        uint256 qty
    ) external view returns(uint256);
}


interface IKyberReserve {
    function getConversionRate(
        IERC20 src,
        IERC20 dest,
        uint256 srcQty,
        uint256 blockNumber
    ) external view returns (uint256);
    
    function conversionRatesContract() external view returns (IConversionRates);
}


contract Utils5 {
    IERC20 internal constant ETH_TOKEN_ADDRESS = IERC20(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    uint256 internal constant PRECISION = (10**18);
    uint256 internal constant MAX_QTY = (10**28); // 10B tokens
    uint256 internal constant MAX_RATE = (PRECISION * 10**7); // up to 10M tokens per eth
    uint256 internal constant MAX_DECIMALS = 18;
    uint256 internal constant ETH_DECIMALS = 18;
    uint256 constant BPS = 10000; // Basic Price Steps. 1 step = 0.01%
    uint256 internal constant MAX_ALLOWANCE = uint256(-1); // token.approve inifinite

    mapping(IERC20 => uint256) internal decimals;

    function getUpdateDecimals(IERC20 token) internal returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint256 tokenDecimals = decimals[token];
        // moreover, very possible that old tokens have decimals 0
        // these tokens will just have higher gas fees.
        if (tokenDecimals == 0) {
            tokenDecimals = token.decimals();
            decimals[token] = tokenDecimals;
        }

        return tokenDecimals;
    }

    function setDecimals(IERC20 token) internal {
        if (decimals[token] != 0) return; //already set

        if (token == ETH_TOKEN_ADDRESS) {
            decimals[token] = ETH_DECIMALS;
        } else {
            decimals[token] = token.decimals();
        }
    }

    /// @dev get the balance of a user.
    /// @param token The token type
    /// @return The balance
    function getBalance(IERC20 token, address user) internal view returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) {
            return user.balance;
        } else {
            return token.balanceOf(user);
        }
    }

    function getDecimals(IERC20 token) internal view returns (uint256) {
        if (token == ETH_TOKEN_ADDRESS) return ETH_DECIMALS; // save storage access
        uint256 tokenDecimals = decimals[token];
        // moreover, very possible that old tokens have decimals 0
        // these tokens will just have higher gas fees.
        if (tokenDecimals == 0) return token.decimals();

        return tokenDecimals;
    }

    function calcDestAmount(
        IERC20 src,
        IERC20 dest,
        uint256 srcAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(
        IERC20 src,
        IERC20 dest,
        uint256 destAmount,
        uint256 rate
    ) internal view returns (uint256) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcDstQty(
        uint256 srcQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(srcQty <= MAX_QTY, "srcQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(
        uint256 dstQty,
        uint256 srcDecimals,
        uint256 dstDecimals,
        uint256 rate
    ) internal pure returns (uint256) {
        require(dstQty <= MAX_QTY, "dstQty > MAX_QTY");
        require(rate <= MAX_RATE, "rate > MAX_RATE");

        //source quantity is rounded up. to avoid dest quantity being too low.
        uint256 numerator;
        uint256 denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcRateFromQty(
        uint256 srcAmount,
        uint256 destAmount,
        uint256 srcDecimals,
        uint256 dstDecimals
    ) internal pure returns (uint256) {
        require(srcAmount <= MAX_QTY, "srcAmount > MAX_QTY");
        require(destAmount <= MAX_QTY, "destAmount > MAX_QTY");

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS, "dst - src > MAX_DECIMALS");
            return ((destAmount * PRECISION) / ((10**(dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS, "src - dst > MAX_DECIMALS");
            return ((destAmount * PRECISION * (10**(srcDecimals - dstDecimals))) / srcAmount);
        }
    }

    function minOf(uint256 x, uint256 y) internal pure returns (uint256) {
        return x > y ? y : x;
    }
}

contract KyberRateQueryHelper is Utils5 {
    
    
    constructor() public  {
        /* empty body */
    }
    
    function getRateWithEth(IKyberReserve reserve, IERC20 token, uint256 weiAmount) public view 
        returns(uint256 sellRate, uint256 buyRate, uint256 tweiAmount) 
    {
        buyRate = IKyberReserve(reserve).getConversionRate(
                    ETH_TOKEN_ADDRESS,
                    token,
                    weiAmount,
                    block.number
                );
        
        if (buyRate == 0) {
            IConversionRates conversionRate = reserve.conversionRatesContract();
            uint tempBuyRate = conversionRate.getRate(token, block.number, true, weiAmount);
            tweiAmount = calcDestAmount(ETH_TOKEN_ADDRESS, token, weiAmount, tempBuyRate);
        } else {
            tweiAmount = calcDestAmount(ETH_TOKEN_ADDRESS, token, weiAmount, buyRate);
        }
        
        sellRate = reserve.getConversionRate(
                    token,
                    ETH_TOKEN_ADDRESS,
                    tweiAmount,
                    block.number
                );
    }

    function getRatesWithEth(IKyberReserve reserve, IERC20[] calldata tokens, uint256 weiAmount) external view 
        returns(uint256[] memory sellRates, uint256[] memory buyRates)
    {
        uint256 numTokens = tokens.length;
     
        buyRates = new uint256[](numTokens);
        sellRates = new uint256[](numTokens);
        for (uint256 i = 0; i < numTokens; i++) {
            (buyRates[i], sellRates[i], ) = getRateWithEth(reserve, tokens[i], weiAmount);
        }   
    }
    
    function getRateWithToken(IKyberReserve reserve, IERC20 token, uint256 tweiAmount) public view 
        returns(uint256 buyRate, uint256 sellRate, uint weiAmount) 
    {
        sellRate = IKyberReserve(reserve).getConversionRate(
                    token,
                    ETH_TOKEN_ADDRESS,
                    tweiAmount,
                    block.number
                );

        if (sellRate == 0) {
            IConversionRates conversionRate = reserve.conversionRatesContract();
            uint tempSellRate = conversionRate.getRate(token, block.number, false, tweiAmount);
            weiAmount = calcDestAmount(token, ETH_TOKEN_ADDRESS, tweiAmount, tempSellRate);
        } else {
            weiAmount = calcDestAmount(token, ETH_TOKEN_ADDRESS, tweiAmount, sellRate);
        }
        
        buyRate = IKyberReserve(reserve).getConversionRate(
                    ETH_TOKEN_ADDRESS,
                    token,
                    weiAmount,
                    block.number
                );
    }

    function getRatesWithToken(IKyberReserve reserve, IERC20[] calldata tokens, uint256 tweiAmount) external view 
        returns(uint256[] memory sellRates, uint256[] memory buyRates)
    {
        uint256 numTokens = tokens.length;
     
        buyRates = new uint256[](numTokens);
        sellRates = new uint256[](numTokens);
        for (uint256 i = 0; i < numTokens; i++) {
            (buyRates[i], sellRates[i], ) = getRateWithEth(reserve, tokens[i], tweiAmount);
        }   
    }
}
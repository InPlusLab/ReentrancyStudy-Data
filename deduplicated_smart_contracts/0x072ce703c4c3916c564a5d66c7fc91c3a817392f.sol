pragma solidity ^0.6.6;
pragma experimental ABIEncoderV2;

import "./IUniswapV2Factory.sol";
import "./IUniswapV2Pair.sol";
import "./IERC20.sol";
import "./IChainLink.sol";
import "./FixedPoint.sol";
import "./UniswapV2OracleLibrary.sol";
import "./UniswapV2Library.sol";
import "./SafeMath.sol";
import "./ITokenOracleDemo.sol";

// fixed window oracle that recomputes the average price for the entire period once every period
// note that the price average is only guaranteed to be over at least 1 period, but may be over a longer period
contract TokenOracleDemo is ITokenOracleDemo {
    using SafeMath for uint;
    using FixedPoint for *;

    //  token的价格的小数位是10位
    uint8 public override constant decimals = 10;

    //  更新pair时，每次最多更新30个，处理速度慢
    uint8 public constant maxUpdatePairCount = 10;

    //  从ChainLink里获取ETH-USD的价格，小数位是8位
    IChainLinkInterface public constant ChainLinkETHUSD = IChainLinkInterface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    
    //  uniswapV2Factory合约的主链地址
    IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    
    //  WETH的主链合约地址
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    //  交易对的信息
    //  没有保存token的name，
    //  原因：如果保存了token的name、symbol，那么结构里会有4个string，会报错：stack too deep等
    //  下一版再优化，token的信息单独作为一个struct，交易对struct里包含2个token的信息
    struct PairInfo {
        IUniswapV2Pair pair;
        address token0;
        address token1;
        string token0Symbol;
        string token1Symbol;
        uint8 token0Decimals;
        uint8 token1Decimals;
        uint price0CumulativeLast;
        uint price1CumulativeLast;
        uint32 blockTimestampLast;
        uint token0Price;
        uint token1Price;
    }
    PairInfo[] public pairInfo;

    //  token价格的数据
    struct tokenPrice {
        address token;
        string symbol;
        uint price;
        uint blockTimestamp;
    }
    tokenPrice[] public tokenPriceData;
    mapping (address => uint) public tokenPriceMap;

    constructor() public {
        //  添加ETH的价格数据
        tokenPrice storage price = tokenPriceData.push();
        price.token = WETH;
        price.symbol = "WETH";
        price.price = uint(ChainLinkETHUSD.latestAnswer()).mul(uint(10)**decimals).div(uint(10)**ChainLinkETHUSD.decimals());
        price.blockTimestamp = block.timestamp;
        tokenPriceMap[WETH] = 0;

        //  解析uniswap交易对，默认先解析10个
        for(uint i = 0; i < 10; i++){
            IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Factory.allPairs(i));
            PairInfo storage _pairInfo = pairInfo.push();
            _pairInfo.pair = pair;
            _pairInfo.token0 = pair.token0();
            _pairInfo.token1 = pair.token1();
            _pairInfo.token0Symbol = IERC20(pair.token0()).symbol();
            _pairInfo.token1Symbol = IERC20(pair.token1()).symbol();
            _pairInfo.token0Decimals = IERC20(pair.token0()).decimals();
            _pairInfo.token1Decimals = IERC20(pair.token1()).decimals();
            _pairInfo.price0CumulativeLast = pair.price0CumulativeLast();
            _pairInfo.price1CumulativeLast = pair.price1CumulativeLast();
            uint112 reserve0;
            uint112 reserve1;
            (reserve0, reserve1, _pairInfo.blockTimestampLast) = pair.getReserves();
        }
    }

    //  获取交易对的数量
    function getPairInfoLength() external override view returns (uint) {
        return pairInfo.length;
    }

    //  检查并更新新的交易队，每次最多更新30个，速度慢，
    //  外部调用函数需要多次调用这个函数，完成交易对的更新
    function updatePairs() external override {
        uint oldLength = pairInfo.length;
        uint newLength = uniswapV2Factory.allPairsLength();
        if (oldLength == newLength)
            return;

        uint count = newLength.sub(oldLength) > maxUpdatePairCount ? maxUpdatePairCount : newLength.sub(oldLength);
        for(uint i = 0; i < count; i++){
            IUniswapV2Pair pair = IUniswapV2Pair(uniswapV2Factory.allPairs(oldLength + i));
            PairInfo storage _pairInfo = pairInfo.push();
            _pairInfo.pair = pair;
            _pairInfo.token0 = pair.token0();
            _pairInfo.token1 = pair.token1();
            _pairInfo.token0Symbol = IERC20(pair.token0()).symbol();
            _pairInfo.token1Symbol = IERC20(pair.token1()).symbol();
            _pairInfo.token0Decimals = IERC20(pair.token0()).decimals();
            _pairInfo.token1Decimals = IERC20(pair.token1()).decimals();
            _pairInfo.price0CumulativeLast = pair.price0CumulativeLast();
            _pairInfo.price1CumulativeLast = pair.price1CumulativeLast();
            uint112 reserve0;
            uint112 reserve1;
            (reserve0, reserve1, _pairInfo.blockTimestampLast) = pair.getReserves();
        }

        emit UpdatePairCount(UniswapV2OracleLibrary.currentBlockTimestamp(), oldLength, newLength, count);
    }

    //  更新所有的交易对的价格
    function updatePairPriceAll () external override {
        for(uint i = 0; i < pairInfo.length; i++){
            updatePairPriceLatest(address(pairInfo[i].pair), i);
        }
        updateTokenPriceUSD();
    }

    //  更新单个交易对的token价格数据
    function updatePairPriceSingle(address pair) external override returns (bool) {

        bool bUpdate = false;
        for(uint i = 0; i < pairInfo.length; i++){
            if (address(pairInfo[i].pair) == pair) {
                bUpdate = updatePairPriceLatest(pair, i);
                updateTokenPriceUSD();
                break;
            }
        }
        return bUpdate;
    }

    //  获取pair的两个token的地址
    function getPairToken(uint index) external override view returns (address pair, address token0, address token1) {
        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (address(pairInfo[index].pair), pairInfo[index].token0, pairInfo[index].token1);
    }

    //  获取pair的两个token的小数位
    function getPairTokenDecimals(uint index) external override view returns (uint8 token0Decimals, uint8 token1Decimals) {
        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (pairInfo[index].token0Decimals, pairInfo[index].token1Decimals);
    }

    //  获取交易对的历史累计价格
    function getPairTokenPriceCumulativeLast(uint index) external override view returns (uint price0CumulativeLast, uint price1CumulativeLast) {
        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (pairInfo[index].price0CumulativeLast, pairInfo[index].price1CumulativeLast);
    }

    //  获取交易对的价格，通过2个token地址
    function getPairPrice(address token0, address token1) external override view returns (uint) {
        for(uint i = 0; i < pairInfo.length; i++) {
            if((pairInfo[i].token0 == token0) && (pairInfo[i].token1 == token1)){
                return pairInfo[i].token0Price;
            }
            if((pairInfo[i].token0 == token1) && (pairInfo[i].token1 == token0)){
                return pairInfo[i].token1Price;
            }
        }           
    }

    //  获取pair的两个token的兑换比例，10位小数位，按数组索引查找
    function getPairPriceByIndex(uint index) external override view returns (address pair, string memory token0Symbol, string memory token1Symbol, uint token0Price, uint token1Price, uint blockTimestamp) {
        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (address(pairInfo[index].pair), pairInfo[index].token0Symbol, pairInfo[index].token1Symbol, pairInfo[index].token0Price, pairInfo[index].token1Price, pairInfo[index].blockTimestampLast);
    }

    //  按交易对的token的symbol查找
    function getPairPriceBySymbol(string calldata token0Symbol, string calldata token1Symbol) external override view returns (address pair, uint token0Price, uint token1Price, uint blockTimestamp) {
        for (uint i = 0; i < pairInfo.length; i++) {
            if ((keccak256(abi.encodePacked(pairInfo[i].token0Symbol)) == keccak256(abi.encodePacked(token0Symbol))) &&
                (keccak256(abi.encodePacked(pairInfo[i].token1Symbol)) == keccak256(abi.encodePacked(token1Symbol)))) {
                    return (address(pairInfo[i].pair), pairInfo[i].token0Price, pairInfo[i].token1Price, pairInfo[i].blockTimestampLast);
            }
        }        
    }

    //  按pair地址查找
    function getPairPriceByAddress(address pair) external override view returns (string memory token0Symbol, string memory token1Symbol, uint token0Price, uint token1Price, uint blockTimestamp) {
        for (uint i = 0; i < pairInfo.length; i++) {
            if (address(pairInfo[i].pair) == pair) {
                return (pairInfo[i].token0Symbol, pairInfo[i].token1Symbol, pairInfo[i].token0Price, pairInfo[i].token1Price, pairInfo[i].blockTimestampLast);
            } 
        }        
    }

    //  获取交易对的数据更新时间
    function getPairUpdatePriceTime(address token0, address token1) external override view returns (uint){
        for(uint i = 0; i < pairInfo.length; i++) {
            if(((pairInfo[i].token0 == token0) && (pairInfo[i].token1 == token1)) ||
                ((pairInfo[i].token0 == token1) && (pairInfo[i].token1 == token0))){
                return pairInfo[i].blockTimestampLast;
            }
        }           
    }

    //  获取有价格的token的数量
    function getTokenLength() external override view returns (uint) {
        return tokenPriceData.length;
    }

    //  获取token的价格
    function getTokenPriceUSD(address token) external override view returns (uint){
        if (token == WETH) {
            return tokenPriceData[tokenPriceMap[WETH]].price;
        } else {
            if (tokenPriceMap[token] == 0) {
                return 0;
            } else {
                return tokenPriceData[tokenPriceMap[token]].price;                
            }
        }
        return 0;
    }

    //  获取token的价格
    function getTokenPriceByIndex(uint index) external override view returns (address token, string memory symbol, uint price, uint blockTimestamp){
        require(index < tokenPriceData.length, "TokenOracle: index is out of range");
        return (tokenPriceData[index].token, tokenPriceData[index].symbol, tokenPriceData[index].price, tokenPriceData[index].blockTimestamp);    
    }

    //  获取token的价格
    function getTokenPriceByAddress(address token) external override view returns (string memory symbol, uint price, uint blockTimestamp) {
        for (uint i = 0; i < tokenPriceData.length; i++) {
            if (address(tokenPriceData[i].token) == token) {
                return (tokenPriceData[i].symbol, tokenPriceData[i].price, tokenPriceData[i].blockTimestamp);
            } 
        }            
    }

    //  获取token的价格
    function getTokenPriceBySymbol(string calldata symbol) external override view returns (address token, uint price, uint blockTimestamp) {
        for (uint i = 0; i < tokenPriceData.length; i++) {
            if (keccak256(abi.encodePacked(tokenPriceData[i].symbol)) == keccak256(abi.encodePacked(symbol))) {
                return (tokenPriceData[i].token, tokenPriceData[i].price, tokenPriceData[i].blockTimestamp);
            } 
        }            
    }

    //  获取token价格的更新时间
    function getTokenPriceUpdateTime(address token) external override view returns (uint){
        if (token == WETH) {
            return tokenPriceData[tokenPriceMap[WETH]].blockTimestamp;
        } else {
            if (tokenPriceMap[token] == 0) {
                return 0;
            } else {
                return tokenPriceData[tokenPriceMap[token]].blockTimestamp;                
            }
        }
        return 0;
    }

    //  更新交易对的最新的交易的价格
    function updatePairPriceLatest(address pair, uint i) internal returns (bool) {

        (uint price0Cumulative, uint price1Cumulative, uint32 blockTimestamp) =
            UniswapV2OracleLibrary.currentCumulativePrices(pair);
        uint32 timeElapsed = blockTimestamp - pairInfo[i].blockTimestampLast; // overflow is desired
        if (timeElapsed == 0) {
            return false;
        }

        // overflow is desired, casting never truncates
        // cumulative price is in (uq112x112 price * seconds) units so we simply wrap it after division by time elapsed
        FixedPoint.uq112x112 memory price0Average = FixedPoint.uq112x112(uint224((price0Cumulative - pairInfo[i].price0CumulativeLast) / timeElapsed));
        FixedPoint.uq112x112 memory price1Average = FixedPoint.uq112x112(uint224((price1Cumulative - pairInfo[i].price1CumulativeLast) / timeElapsed));
        
        pairInfo[i].price0CumulativeLast = price0Cumulative;
        pairInfo[i].price1CumulativeLast = price1Cumulative;
        pairInfo[i].blockTimestampLast = blockTimestamp;

        //  priceAverage * 分子的token的Decimals / 分母的token的Decimals * 本合约的10位小数
        pairInfo[i].token0Price = uint(price0Average.mul(uint(10)**pairInfo[i].token0Decimals).decode144()).mul(uint(10)**decimals).div(uint(10)**pairInfo[i].token1Decimals);
        pairInfo[i].token1Price = uint(price1Average.mul(uint(10)**pairInfo[i].token1Decimals).decode144()).mul(uint(10)**decimals).div(uint(10)**pairInfo[i].token0Decimals);

        emit UpdatePairPriceLatest(pair, pairInfo[i].token0Price, pairInfo[i].token1Price, UniswapV2OracleLibrary.currentBlockTimestamp());

        return true;
    }

    // 新建token的价格数据
    function newTokenPriceData(uint index) internal {
        if ((tokenPriceMap[pairInfo[index].token0] == 0) && (pairInfo[index].token0 != WETH)){
            tokenPrice storage price = tokenPriceData.push();
            price.token = pairInfo[index].token0;
            price.symbol = pairInfo[index].token0Symbol;
            price.price = 0;
            price.blockTimestamp = 0;
            tokenPriceMap[pairInfo[index].token0] = tokenPriceData.length - 1;
        } 
        if ((tokenPriceMap[pairInfo[index].token1] == 0) && (pairInfo[index].token1 != WETH)) {
            tokenPrice storage price = tokenPriceData.push();
            price.token = pairInfo[index].token1;
            price.symbol = pairInfo[index].token1Symbol;
            price.price = 0;
            price.blockTimestamp = 0;
            tokenPriceMap[pairInfo[index].token1] = tokenPriceData.length - 1;
        }         
    }

    //  计算token的usd价格
    //  pair里的token0、token1，没有与其他token的交易对，无法计算这2个token美元价格
    function updateTokenPriceUSD() internal {
        // 把ChainLink的ETH的价格的8位小数转为10位小数
        uint ethPrice = uint(ChainLinkETHUSD.latestAnswer()).mul(uint(10)**decimals).div(uint(10)**ChainLinkETHUSD.decimals());
        tokenPriceData[tokenPriceMap[WETH]].price = ethPrice;
        tokenPriceData[tokenPriceMap[WETH]].blockTimestamp = block.timestamp;

        //  处理所有的ETH交易对，计算另外一个token的价格
        for(uint i = 0; i < pairInfo.length; i++){
            newTokenPriceData(i);
            if(pairInfo[i].token0 == WETH) {
                if(pairInfo[i].blockTimestampLast > tokenPriceData[tokenPriceMap[pairInfo[i].token1]].blockTimestamp){
                    tokenPriceData[tokenPriceMap[pairInfo[i].token1]].price = pairInfo[i].token1Price.mul(ethPrice).div(uint(10)**decimals);
                    tokenPriceData[tokenPriceMap[pairInfo[i].token1]].blockTimestamp = pairInfo[i].blockTimestampLast;
                }
            }    
            if(pairInfo[i].token1 == WETH) {
                if(pairInfo[i].blockTimestampLast > tokenPriceData[tokenPriceMap[pairInfo[i].token0]].blockTimestamp){
                    tokenPriceData[tokenPriceMap[pairInfo[i].token0]].price = pairInfo[i].token0Price.mul(ethPrice).div(uint(10)**decimals);
                    tokenPriceData[tokenPriceMap[pairInfo[i].token0]].blockTimestamp = pairInfo[i].blockTimestampLast;
                }
            }    
        }

        //  处理交易对里没有ETH的交易对，根据tokenA的价格，计算tokenB的价格，
        //  遍历5次，如果5级路由还无法确定某个token的价格，那么就不计算了
        for (uint m = 0; m < 5; m++) {
            for(uint i = 0; i < pairInfo.length; i++){
                if((pairInfo[i].token0 == WETH) || (pairInfo[i].token1 == WETH)) {
                    continue;
                }
                newTokenPriceData(i);
                if(tokenPriceData[tokenPriceMap[pairInfo[i].token1]].price != 0) {
                    if(pairInfo[i].blockTimestampLast > tokenPriceData[tokenPriceMap[pairInfo[i].token0]].blockTimestamp){
                        tokenPriceData[tokenPriceMap[pairInfo[i].token0]].price = pairInfo[i].token0Price.mul(tokenPriceData[tokenPriceMap[pairInfo[i].token1]].price).div(uint(10)**decimals);
                        tokenPriceData[tokenPriceMap[pairInfo[i].token0]].blockTimestamp = pairInfo[i].blockTimestampLast;
                    }
                }
                if(tokenPriceData[tokenPriceMap[pairInfo[i].token0]].price != 0) {
                    if(pairInfo[i].blockTimestampLast > tokenPriceData[tokenPriceMap[pairInfo[i].token1]].blockTimestamp){
                        tokenPriceData[tokenPriceMap[pairInfo[i].token1]].price = pairInfo[i].token1Price.mul(tokenPriceData[tokenPriceMap[pairInfo[i].token0]].price).div(uint(10)**decimals);
                        tokenPriceData[tokenPriceMap[pairInfo[i].token1]].blockTimestamp = pairInfo[i].blockTimestampLast;
                    }
                }
            }            
        }
    }

}

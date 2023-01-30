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

    //  token�ļ۸��С��λ��10λ
    uint8 public override constant decimals = 10;

    //  ����pairʱ��ÿ��������30���������ٶ���
    uint8 public constant maxUpdatePairCount = 10;

    //  ��ChainLink���ȡETH-USD�ļ۸�С��λ��8λ
    IChainLinkInterface public constant ChainLinkETHUSD = IChainLinkInterface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    
    //  uniswapV2Factory��Լ��������ַ
    IUniswapV2Factory public constant uniswapV2Factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);
    
    //  WETH��������Լ��ַ
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    //  ���׶Ե���Ϣ
    //  û�б���token��name��
    //  ԭ�����������token��name��symbol����ô�ṹ�����4��string���ᱨ��stack too deep��
    //  ��һ�����Ż���token����Ϣ������Ϊһ��struct�����׶�struct�����2��token����Ϣ
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

    //  token�۸������
    struct tokenPrice {
        address token;
        string symbol;
        uint price;
        uint blockTimestamp;
    }
    tokenPrice[] public tokenPriceData;
    mapping (address => uint) public tokenPriceMap;

    constructor() public {
        //  ���ETH�ļ۸�����
        tokenPrice storage price = tokenPriceData.push();
        price.token = WETH;
        price.symbol = "WETH";
        price.price = uint(ChainLinkETHUSD.latestAnswer()).mul(uint(10)**decimals).div(uint(10)**ChainLinkETHUSD.decimals());
        price.blockTimestamp = block.timestamp;
        tokenPriceMap[WETH] = 0;

        //  ����uniswap���׶ԣ�Ĭ���Ƚ���10��
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

    //  ��ȡ���׶Ե�����
    function getPairInfoLength() external override view returns (uint) {
        return pairInfo.length;
    }

    //  ��鲢�����µĽ��׶ӣ�ÿ��������30�����ٶ�����
    //  �ⲿ���ú�����Ҫ��ε��������������ɽ��׶Եĸ���
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

    //  �������еĽ��׶Եļ۸�
    function updatePairPriceAll () external override {
        for(uint i = 0; i < pairInfo.length; i++){
            updatePairPriceLatest(address(pairInfo[i].pair), i);
        }
        updateTokenPriceUSD();
    }

    //  ���µ������׶Ե�token�۸�����
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

    //  ��ȡpair������token�ĵ�ַ
    function getPairToken(uint index) external override view returns (address pair, address token0, address token1) {
        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (address(pairInfo[index].pair), pairInfo[index].token0, pairInfo[index].token1);
    }

    //  ��ȡpair������token��С��λ
    function getPairTokenDecimals(uint index) external override view returns (uint8 token0Decimals, uint8 token1Decimals) {
        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (pairInfo[index].token0Decimals, pairInfo[index].token1Decimals);
    }

    //  ��ȡ���׶Ե���ʷ�ۼƼ۸�
    function getPairTokenPriceCumulativeLast(uint index) external override view returns (uint price0CumulativeLast, uint price1CumulativeLast) {
        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (pairInfo[index].price0CumulativeLast, pairInfo[index].price1CumulativeLast);
    }

    //  ��ȡ���׶Եļ۸�ͨ��2��token��ַ
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

    //  ��ȡpair������token�Ķһ�������10λС��λ����������������
    function getPairPriceByIndex(uint index) external override view returns (address pair, string memory token0Symbol, string memory token1Symbol, uint token0Price, uint token1Price, uint blockTimestamp) {
        require(index < pairInfo.length, "TokenOracle: index is out of range");
        return (address(pairInfo[index].pair), pairInfo[index].token0Symbol, pairInfo[index].token1Symbol, pairInfo[index].token0Price, pairInfo[index].token1Price, pairInfo[index].blockTimestampLast);
    }

    //  �����׶Ե�token��symbol����
    function getPairPriceBySymbol(string calldata token0Symbol, string calldata token1Symbol) external override view returns (address pair, uint token0Price, uint token1Price, uint blockTimestamp) {
        for (uint i = 0; i < pairInfo.length; i++) {
            if ((keccak256(abi.encodePacked(pairInfo[i].token0Symbol)) == keccak256(abi.encodePacked(token0Symbol))) &&
                (keccak256(abi.encodePacked(pairInfo[i].token1Symbol)) == keccak256(abi.encodePacked(token1Symbol)))) {
                    return (address(pairInfo[i].pair), pairInfo[i].token0Price, pairInfo[i].token1Price, pairInfo[i].blockTimestampLast);
            }
        }        
    }

    //  ��pair��ַ����
    function getPairPriceByAddress(address pair) external override view returns (string memory token0Symbol, string memory token1Symbol, uint token0Price, uint token1Price, uint blockTimestamp) {
        for (uint i = 0; i < pairInfo.length; i++) {
            if (address(pairInfo[i].pair) == pair) {
                return (pairInfo[i].token0Symbol, pairInfo[i].token1Symbol, pairInfo[i].token0Price, pairInfo[i].token1Price, pairInfo[i].blockTimestampLast);
            } 
        }        
    }

    //  ��ȡ���׶Ե����ݸ���ʱ��
    function getPairUpdatePriceTime(address token0, address token1) external override view returns (uint){
        for(uint i = 0; i < pairInfo.length; i++) {
            if(((pairInfo[i].token0 == token0) && (pairInfo[i].token1 == token1)) ||
                ((pairInfo[i].token0 == token1) && (pairInfo[i].token1 == token0))){
                return pairInfo[i].blockTimestampLast;
            }
        }           
    }

    //  ��ȡ�м۸��token������
    function getTokenLength() external override view returns (uint) {
        return tokenPriceData.length;
    }

    //  ��ȡtoken�ļ۸�
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

    //  ��ȡtoken�ļ۸�
    function getTokenPriceByIndex(uint index) external override view returns (address token, string memory symbol, uint price, uint blockTimestamp){
        require(index < tokenPriceData.length, "TokenOracle: index is out of range");
        return (tokenPriceData[index].token, tokenPriceData[index].symbol, tokenPriceData[index].price, tokenPriceData[index].blockTimestamp);    
    }

    //  ��ȡtoken�ļ۸�
    function getTokenPriceByAddress(address token) external override view returns (string memory symbol, uint price, uint blockTimestamp) {
        for (uint i = 0; i < tokenPriceData.length; i++) {
            if (address(tokenPriceData[i].token) == token) {
                return (tokenPriceData[i].symbol, tokenPriceData[i].price, tokenPriceData[i].blockTimestamp);
            } 
        }            
    }

    //  ��ȡtoken�ļ۸�
    function getTokenPriceBySymbol(string calldata symbol) external override view returns (address token, uint price, uint blockTimestamp) {
        for (uint i = 0; i < tokenPriceData.length; i++) {
            if (keccak256(abi.encodePacked(tokenPriceData[i].symbol)) == keccak256(abi.encodePacked(symbol))) {
                return (tokenPriceData[i].token, tokenPriceData[i].price, tokenPriceData[i].blockTimestamp);
            } 
        }            
    }

    //  ��ȡtoken�۸�ĸ���ʱ��
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

    //  ���½��׶Ե����µĽ��׵ļ۸�
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

        //  priceAverage * ���ӵ�token��Decimals / ��ĸ��token��Decimals * ����Լ��10λС��
        pairInfo[i].token0Price = uint(price0Average.mul(uint(10)**pairInfo[i].token0Decimals).decode144()).mul(uint(10)**decimals).div(uint(10)**pairInfo[i].token1Decimals);
        pairInfo[i].token1Price = uint(price1Average.mul(uint(10)**pairInfo[i].token1Decimals).decode144()).mul(uint(10)**decimals).div(uint(10)**pairInfo[i].token0Decimals);

        emit UpdatePairPriceLatest(pair, pairInfo[i].token0Price, pairInfo[i].token1Price, UniswapV2OracleLibrary.currentBlockTimestamp());

        return true;
    }

    // �½�token�ļ۸�����
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

    //  ����token��usd�۸�
    //  pair���token0��token1��û��������token�Ľ��׶ԣ��޷�������2��token��Ԫ�۸�
    function updateTokenPriceUSD() internal {
        // ��ChainLink��ETH�ļ۸��8λС��תΪ10λС��
        uint ethPrice = uint(ChainLinkETHUSD.latestAnswer()).mul(uint(10)**decimals).div(uint(10)**ChainLinkETHUSD.decimals());
        tokenPriceData[tokenPriceMap[WETH]].price = ethPrice;
        tokenPriceData[tokenPriceMap[WETH]].blockTimestamp = block.timestamp;

        //  �������е�ETH���׶ԣ���������һ��token�ļ۸�
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

        //  �����׶���û��ETH�Ľ��׶ԣ�����tokenA�ļ۸񣬼���tokenB�ļ۸�
        //  ����5�Σ����5��·�ɻ��޷�ȷ��ĳ��token�ļ۸���ô�Ͳ�������
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

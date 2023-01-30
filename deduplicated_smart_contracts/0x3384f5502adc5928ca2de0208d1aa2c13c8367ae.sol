/**
 *Submitted for verification at Etherscan.io on 2020-06-14
*/

pragma solidity ^0.5.0;

// "SPDX-License-Identifier: UNLICENSED"

interface ERC20 {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) external view returns (uint balance);
    function allowance(address tokenOwner, address spender) external view returns (uint remaining);
    function transfer(address to, uint tokens) external returns (bool success);
    function approve(address spender, uint tokens) external returns (bool success);
    function transferFrom(address from, address to, uint tokens) external returns (bool success);
 
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

interface ERCIndex {
    function topTokensLength() external returns (uint);
    function getTokenAddressAndBalance(uint index) external returns (ERC20, uint);
}

contract UniswapFactoryInterface {
    // Public Variables
    address public exchangeTemplate;
    uint256 public tokenCount;
    // Create Exchange
    function createExchange(address token) external returns (address exchange);
    // Get Exchange and Token Info
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
    // Never use
    function initializeFactory(address template) external;
}

contract UniswapExchangeInterface {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    // function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    // function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    // function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    // function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    // function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    // function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    // function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    // function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    // function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    // function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    // function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    // function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

contract MyUniswapProxy {
    
    UniswapFactoryInterface factory;

    ERCIndex ercIndex;
    
    bool public contractSet = false;
    
    ERC20 daiToken = ERC20(0x2448eE2641d78CC42D7AD76498917359D961A783); // Rinkeby
    // ERC20 daiToken = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F); // mainnet
    
    constructor () public {

        // factory = UniswapFactoryInterface(0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36); // rinkeby
        factory = UniswapFactoryInterface(0xc0a47dFe034B400B47bDaD5FecDa2621de6c4d95); // mainnet

    }
    
    // Functions 
    
    // make the erc index contract address a constant
    function setERCIndexContract(address _address) public {
        
        require(!contractSet);
        
        ercIndex = ERCIndex(_address);
        
        contractSet = true;
        
    }
    
    /*
    Main function, called from ERCIndex contract
    It reads the balances of the ERCindex contract tokens and calculates their respective values (in DAI)
    It calculates target values and returns the index of the two tokens most behind their target value
    
    // use this linear calculation for lower gas costs
    */
    function calculateIndexValueAndNext2Tokens(uint _numberOfTokens) public returns(uint, uint, uint) {
        
        require(_numberOfTokens > 0);
        
        ERC20 token; // token instance
        
        uint rate; // token's rate
        
        uint tokenBalance; // token's balance
        
        uint tokenBalanceEth; // token's eth value (rate * balance)
        
        uint ethValue = 0; // sum value of all tokens
        
        uint indexOfTokenWithLowestBalance = 0;
        uint lowestBalance = uint(-1);
        
        uint indexOfTokenWithLowestBalance2 = 0;
        uint lowestBalance2 = uint(-1);
        
        // caluclate value of each token in for loop - O(n)
        for (uint i = 0; i < _numberOfTokens; i++) {
            
            (token, tokenBalance) = ercIndex.getTokenAddressAndBalance(i);
            
            rate = getTokenEthPrice(address(token)); // 1 token is x ETH * (10 ** 18)
            
            tokenBalanceEth = rate * tokenBalance;
            
            ethValue += tokenBalanceEth;
            
            if (tokenBalanceEth < lowestBalance) {
                
                lowestBalance2 = lowestBalance;
                indexOfTokenWithLowestBalance2 = indexOfTokenWithLowestBalance;
                
                indexOfTokenWithLowestBalance = i;
                lowestBalance = tokenBalanceEth;
                
            } else if (tokenBalanceEth < lowestBalance2) {
                
                indexOfTokenWithLowestBalance2 = i;
                lowestBalance2 = tokenBalanceEth;
                
            }
            
        }
        
        uint daiValue = daiToken.balanceOf(address(ercIndex));
        
        // calculate total value of ERCIndex conract (excluding dai holdings=)
        daiValue += ethValue / getTokenEthPrice(address(daiToken)); // DAIEUR > 0
        
        return (daiValue, indexOfTokenWithLowestBalance, indexOfTokenWithLowestBalance2);
    
        // note - marketCaps and Value & token Values must all be all in the same currency (eth in this case)
        // return (daiValue, calculateBiggestDifference(_numberOfTokens, marketCaps, ethValue, tokenEthValues));
        
    }
    
    /*
    Main function, called from ERCIndex contract
    It reads the balances of the ERCindex contract tokens and calculates their respective values (in DAI)
    It calculates target values and return the index of the token which is most behing its target value
    */
    /*function calculateIndexValueAndNextTokenIndex(uint _numberOfTokens) public returns(uint, uint) {
        
        require(_numberOfTokens > 0);
        
        uint ethValue = 0; // sum value of all tokens
        
        ERC20 token; // token instance
        
        uint rate; // token's rate
        
        uint tokenBalance; // token's balakce
        
        uint tokenEthValue; // token's eth value (rate * balance)
        
        uint[] memory tokenEthValues = new uint[](_numberOfTokens);
        
        uint[] memory marketCaps = new uint[](_numberOfTokens);
        
        // caluclate value of each token in for loop - O(n)
        for (uint i = 0; i < _numberOfTokens; i++) {
            
            (token, tokenBalance) = ercIndex.getTokenAddressAndBalance(i);
            
            rate = getTokenEthPrice(address(token)); // 1 token is x ETH * (10 ** 18)
            
            tokenEthValue = rate * tokenBalance;
            
            tokenEthValues[i] = tokenEthValue;
            
            marketCaps[i] = rate * token.totalSupply(); // of
            
            ethValue += tokenEthValue;
            
        }
        
        uint daiValue = daiToken.balanceOf(address(ercIndex));
        
        // calculate total value of ERCIndex conract (excluding dai holdings=)
        daiValue += ethValue / getTokenEthPrice(address(daiToken)); // DAIEUR > 0
    
        // note - marketCaps and Value & token Values must all be all in the same currency (eth in this case)
        return (daiValue, calculateBiggestDifference(_numberOfTokens, marketCaps, ethValue, tokenEthValues));
        
    }*/
    
    /*
    
        Logic for calculating target values for each coin and returning the coin that should be bought - O(n^2)
    
        Recieve market cap of each token in ETH;
        From token with biggest market cap to token with smallest:
        calculate target index value for token, based on number of tokens, total daiAmount in index and the number of tokens
        (target is linearly decreasing with market cap order of token)
        return index of token that has the biggest difference between the index's token holdings and the target balance
    */
    /*function calculateBiggestDifference(uint _numberOfTokens, uint[] memory _marketCaps, uint _indexValue, uint[] memory _tokenDaiValues) public pure returns (uint) {
    
        uint biggestMcap = 0;
        
        uint biggestMcapIndex = 0;
        
        uint biggestDifference = 0;
        
        uint biggestDifferenceIndex = 0; // index of token that has the biggest difference from the target value
        
        uint baseAmount = _indexValue / (_numberOfTokens * 2);
        
        uint j;
        
        // n - times / for each token ...
        for (uint i = 0; i < _numberOfTokens; i++) {

            // find the token with the next hightest marketCap (biggestMcapIndex)
            for (j = 0; j < _numberOfTokens; j++) {
                
                if (_marketCaps[j] > biggestMcap) {
                    
                    biggestMcap = _marketCaps[j];
                    
                    biggestMcapIndex = j;
                
                }
                
            }
            
            biggestMcap = 0;
            
            _marketCaps[biggestMcapIndex] = 0;
            
            // target value is calculated with O(1) complexity
            uint targetValue = baseAmount + ((baseAmount * ((_numberOfTokens * 2) - (1 + (2 * i)))) / _numberOfTokens);
            
            // remember which token has the biggest difference from its target value
            if (_tokenDaiValues[biggestMcapIndex] < targetValue && targetValue - _tokenDaiValues[biggestMcapIndex] > biggestDifference) {
                
                biggestDifference = targetValue - _tokenDaiValues[biggestMcapIndex];
                
                biggestDifferenceIndex = biggestMcapIndex;
                
            }
            
        }
        
        return biggestDifferenceIndex;
    
    }*/
    
    function getTokenEthPrice(address _token) public view returns (uint) {
        // rinkeby DAI: 0x2448eE2641d78CC42D7AD76498917359D961A783
        // rinkeby BAT: 0xDA5B056Cfb861282B4b59d29c9B395bcC238D29B
        // rinkeby MKR: 0xF9bA5210F91D0474bd1e1DcDAeC4C58E359AaD85
        // rinkeby OMG: 0x879884c3C46A24f56089f3bBbe4d5e38dB5788C0
        // rinkeby ZRX: 0xF22e3F33768354c9805d046af3C0926f27741B43

        address exchange = factory.getExchange(_token);
        
        uint tokenReserve = ERC20(_token).balanceOf(exchange);
        
        uint ethReserve = exchange.balance;
        
        if (tokenReserve == 0) {
            
            return 0;
            
        } else {
            
            return (ethReserve * (10 ** 18)) / tokenReserve;
        
        }
        
    }
    
    // ERCIndex calls this function to execute ERC swaps
    function executeSwap(ERC20 _srcToken, uint _tokensSold, address _destToken, address _destAddress) public {
        
        // Check that the token transferFrom has succeeded
        // use sender instead of msg.sender because thiss will be called by another ERCIndex
        require(_srcToken.transferFrom(msg.sender, address(this), _tokensSold));

        UniswapExchangeInterface exchange = UniswapExchangeInterface(factory.getExchange(address(_srcToken)));
        
        require(!(address(exchange) == address(0)));
        
        // Mitigate ERC20 Approve front-running attack, by initially setting
        // allowance to 0
        require(_srcToken.approve(address(exchange), 0));

        // Set the spender's token allowance to tokenQty
        require(_srcToken.approve(address(exchange), _tokensSold));
        
        // tokens_sold: uint256,
        // min_tokens_bought: uint256,
        // min_eth_bought: uint256,
        // deadline: uint256,
        // recipient: address
        // token_addr: address
        exchange.tokenToTokenTransferInput(_tokensSold, 1, 1, now + 10 minutes, _destAddress, _destToken);
    }
    
    /*
    will be used when purchasing with ETH is enabled
    function ethToTokenTransferInput(ERC20 _token) external payable returns (uint256 tokens_bought) {
        UniswapExchangeInterface exchange = UniswapExchangeInterface(factory.getExchange(address(_token)));
        // uint256 min_tokens, uint256 deadline, address recipient
        return exchange.ethToTokenTransferInput.value(msg.value)(1, now + 10 minutes, msg.sender);
        
    }*/
    
}
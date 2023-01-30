/**

 *Submitted for verification at Etherscan.io on 2018-12-25

*/



contract Exchange{

    // Providing Liquidity

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) public returns(uint256);

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) public returns(uint256, uint256); 

    // Trading 

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) public returns(uint256);

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) public returns(uint256); 

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) public returns(uint256); 

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) public returns(uint256); 

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) public returns(uint256); 

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) public returns(uint256); 

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) public returns(uint256); 

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) public returns(uint256); 

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) public returns(uint256); 

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) public returns(uint256); 

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) public returns(uint256); 

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) public returns(uint256); 

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) public returns(uint256); 

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) public returns(uint256); 

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) public returns(uint256); 

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) public returns(uint256); 

    // Get Price

    function getEthToTokenInputPrice(uint256 eth_sold) view public returns(uint256);

    function getEthToTokenOutputPrice(uint256 tokens_bought) public returns(uint256);

    function getTokenToEthInputPrice(uint256 tokens_sold) public returns(uint256);

    function getTokenToEthOutputPrice(uint256 eth_bought) public returns(uint256);

    // Public Variables

    function tokenAddress() view public returns(address);

    function factoryAddress() view public returns(address);

    // Pool Token ERC20 Compatibility

    function balanceOf() view public returns(address);

    function allowance(address _owner , address _spender ) view public returns(uint256);

    function transfer(address _to , uint256 _value ) public returns(bool); 

    function transferFrom(address _from , address _to , uint256 _value ) public returns(bool);

    function approve(address _spender , uint256 _value ) public returns(bool);                        

}



contract Test is Exchange {

    uint x;

    address y;



    // Providing Liquidity

    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) public returns(uint256) {

        return x;

    }

    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) public returns(uint256, uint256) {

        return (x,x);

    }

    // Trading 

    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) public returns(uint256) {

        return x;

    }

    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) public returns(uint256) {

        return x;

    } 

    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) public returns(uint256) {

        return x;

    }

    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) public returns(uint256) {

        return x;

    }

    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) public returns(uint256) {

        return x;

    }

    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline, address recipient) public returns(uint256) {

        return x;

    }

    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) public returns(uint256) {

        return x;

    }

    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) public returns(uint256) {

        return x;

    }

    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) public returns(uint256) {

        return x;

    }

    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) public returns(uint256) {

        return x;

    }

    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) public returns(uint256) {

        return x;

    }

    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) public returns(uint256) {

        return x;

    }

    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) public returns(uint256) {

        return x;

    }

    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) public returns(uint256) {

        return x;

    }

    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) public returns(uint256) {

        return x;

    }

    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) public returns(uint256) {

        return x;

    }

    // Get Price

    function getEthToTokenInputPrice(uint256 eth_sold) view public returns(uint256) {

        return x;

    }

    function getEthToTokenOutputPrice(uint256 tokens_bought) public returns(uint256) {

        return x;

    }

    function getTokenToEthInputPrice(uint256 tokens_sold) public returns(uint256) {

        return x;

    }

    function getTokenToEthOutputPrice(uint256 eth_bought) public returns(uint256) {

        return x;

    }

    // Public Variables

    function tokenAddress() view public returns(address) {

        return y;

    }

    function factoryAddress() view public returns(address) {

        return y;

    }

    // Pool Token ERC20 Compatibility

    function balanceOf() view public returns(address) {

        return y;

    }

    function allowance(address _owner , address _spender ) view public returns(uint256) {

        return x;

    }

    function transfer(address _to , uint256 _value ) public returns(bool) {

        return x == 0;

    } 

    function transferFrom(address _from , address _to , uint256 _value ) public returns(bool) {

        return x == 0;

    }

    function approve(address _spender , uint256 _value ) public returns(bool) {

        return x == 0;

    }                        

    

    

}